//! Opt-in, process-wide Arti diagnostics with bounded native storage.
//!
//! Pulling batches instead of pushing individual FFI messages keeps a paused Dart consumer from building an unbounded isolate mailbox. No task, I/O, or blocking channel send runs on a Tor event's thread.

use std::fmt::{self, Write as _};
use std::net::Ipv6Addr;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::{Arc, Mutex, OnceLock};

use flutter_rust_bridge::frb;
use regex::Regex;
use tokio::sync::{mpsc, watch, Mutex as AsyncMutex, Notify};
use tracing::field::{Field, Visit};
use tracing::subscriber::Interest;
use tracing::{Event, Level, Metadata, Subscriber};
use tracing_subscriber::filter::{LevelFilter, Targets};
use tracing_subscriber::layer::{Context, SubscriberExt as _};
use tracing_subscriber::{Layer, Registry};

use super::error::TorFailure;

const DEFAULT_FILTER: &str = "onion=debug,tor_hsclient=debug,tor_circmgr=info,tor_guardmgr=info,tor_dirmgr=info,arti_client=info,tor_proto=warn,warn";
const CAPACITY: usize = 1024;
const BATCH_SIZE: usize = 64;
const MAX_MESSAGE_CHARS: usize = 512;
const MAX_FORMAT_BYTES: usize = 8192;

/// Severity of an embedded Tor diagnostic. Trace is never captured.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TorLogLevel {
    /// An operation failed; this does not imply the whole client failed.
    Error,
    /// A recoverable problem or degraded operation.
    Warn,
    /// An operational milestone.
    Info,
    /// Detailed developer diagnostics, normally console-only in a host app.
    Debug,
}

/// Redacted diagnostic text, not a stable protocol or a localized UI message.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TorLogRecord {
    /// Native severity, without host-specific persistence/reporting policy.
    pub level: TorLogLevel,
    /// Rust module target, useful for distinguishing HS, circuit and guard work.
    pub target: String,
    /// Single-line message and structured fields, at most 512 Unicode characters.
    pub message: String,
}

/// Counters for this capture, plus process-wide routing contention.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TorLogStats {
    /// Records accepted into this capture's native queue.
    pub accepted: u64,
    /// Records lost because this capture's queue was full.
    pub dropped: u64,
    /// Event/span routing lookups skipped while the routing mutex was busy. Cumulative across captures; compare snapshots for an interval.
    pub routing_dropped: u64,
}

struct Capture {
    sender: mpsc::Sender<TorLogRecord>,
    filter: Targets,
    closed: watch::Sender<bool>,
    stopped: AtomicBool,
    accepted: AtomicU64,
    dropped: AtomicU64,
    pending_dropped: AtomicU64,
    overflow: Notify,
}

impl Capture {
    fn push(&self, record: impl FnOnce() -> TorLogRecord) {
        match self.sender.try_reserve() {
            Ok(permit) => {
                permit.send(record());
                self.accepted.fetch_add(1, Ordering::Relaxed);
            }
            Err(mpsc::error::TrySendError::Full(_)) => {
                self.record_drop();
            }
            Err(mpsc::error::TrySendError::Closed(_)) => {}
        }
    }

    fn record_drop(&self) {
        self.dropped.fetch_add(1, Ordering::Relaxed);
        self.pending_dropped.fetch_add(1, Ordering::Relaxed);
        self.overflow.notify_one();
    }

    async fn wait_for_loss(&self) {
        while self.pending_dropped.load(Ordering::Relaxed) == 0 {
            self.overflow.notified().await;
        }
    }

    fn stop(&self) {
        self.stopped.store(true, Ordering::Relaxed);
        self.closed.send_replace(true);
    }
}

struct Router {
    active: Mutex<Option<Arc<Capture>>>,
    routing_dropped: AtomicU64,
}

impl Router {
    fn new() -> Self {
        Self {
            active: Mutex::new(None),
            routing_dropped: AtomicU64::new(0),
        }
    }

    fn capture(&self) -> Option<Arc<Capture>> {
        match self.active.try_lock() {
            Ok(active) => active.clone(),
            Err(_) => {
                self.routing_dropped.fetch_add(1, Ordering::Relaxed);
                None
            }
        }
    }

    fn open(self: &Arc<Self>, filter: Targets) -> TorLogStream {
        // Initialize regexes on the registering caller, never on the first
        // Tor event (where other logging threads could wait for OnceLock).
        let _ = redact("");
        let (sender, receiver) = mpsc::channel(CAPACITY);
        let capture = Arc::new(Capture {
            sender,
            filter,
            closed: watch::channel(false).0,
            stopped: AtomicBool::new(false),
            accepted: AtomicU64::new(0),
            dropped: AtomicU64::new(0),
            pending_dropped: AtomicU64::new(0),
            overflow: Notify::new(),
        });
        let previous = self
            .active
            .lock()
            .unwrap_or_else(|p| p.into_inner())
            .replace(Arc::clone(&capture));
        if let Some(previous) = previous {
            previous.stop();
        }
        TorLogStream {
            capture,
            receiver: AsyncMutex::new(receiver),
            router: Arc::clone(self),
        }
    }
}

struct LogLayer(Arc<Router>);

impl<S: Subscriber> Layer<S> for LogLayer {
    fn register_callsite(&self, _: &'static Metadata<'static>) -> Interest {
        // A capture can be replaced with a different filter at any time.
        Interest::sometimes()
    }

    fn max_level_hint(&self) -> Option<LevelFilter> {
        Some(LevelFilter::DEBUG)
    }

    fn enabled(&self, meta: &Metadata<'_>, _: Context<'_, S>) -> bool {
        *meta.level() != Level::TRACE
            && self.0.capture().is_some_and(|capture| {
                !capture.stopped.load(Ordering::Relaxed)
                    && capture.filter.would_enable(meta.target(), meta.level())
            })
    }

    fn on_event(&self, event: &Event<'_>, _: Context<'_, S>) {
        let meta = event.metadata();
        let Some(capture) = self.0.capture() else {
            return;
        };
        if *meta.level() == Level::TRACE
            || capture.stopped.load(Ordering::Relaxed)
            || !capture.filter.would_enable(meta.target(), meta.level())
        {
            return;
        }
        capture.push(|| {
            let mut fields = Fields::new();
            event.record(&mut fields);
            let message = if fields.overflow {
                "Tor log record omitted (oversized)".to_owned()
            } else {
                redact(&fields.text)
                    .chars()
                    .map(|c| if c.is_control() { ' ' } else { c })
                    .take(MAX_MESSAGE_CHARS)
                    .collect()
            };
            let level = match *meta.level() {
                Level::ERROR => TorLogLevel::Error,
                Level::WARN => TorLogLevel::Warn,
                Level::INFO => TorLogLevel::Info,
                _ => TorLogLevel::Debug,
            };
            TorLogRecord {
                level,
                target: meta.target().chars().take(128).collect(),
                message,
            }
        });
    }
}

struct Fields {
    text: String,
    overflow: bool,
}

impl Fields {
    fn new() -> Self {
        Self {
            text: String::new(),
            overflow: false,
        }
    }
}

impl fmt::Write for Fields {
    fn write_str(&mut self, text: &str) -> fmt::Result {
        if self.overflow || self.text.len().saturating_add(text.len()) > MAX_FORMAT_BYTES {
            self.overflow = true;
            return Err(fmt::Error);
        }
        self.text.push_str(text);
        Ok(())
    }
}

impl Visit for Fields {
    fn record_debug(&mut self, field: &Field, value: &dyn fmt::Debug) {
        if !self.text.is_empty() {
            let _ = self.write_char(' ');
        }
        if field.name() != "message" {
            let _ = write!(self, "{}=", field.name());
        }
        let _ = write!(self, "{value:?}");
    }

    fn record_str(&mut self, field: &Field, value: &str) {
        if !self.text.is_empty() {
            let _ = self.write_char(' ');
        }
        if field.name() != "message" {
            let _ = write!(self, "{}=", field.name());
        }
        let _ = self.write_str(value);
    }
}

fn redact(text: &str) -> String {
    static ADDRESSES: OnceLock<Regex> = OnceLock::new();
    static IPV6_TOKENS: OnceLock<Regex> = OnceLock::new();
    let addresses = ADDRESSES.get_or_init(|| {
        Regex::new(r"(?i)[a-z2-7]{56}\.onion|(?:[0-9]{1,3}\.){3}[0-9]{1,3}|[0-9a-f]{64}")
            .expect("constant address regex")
    });
    let ipv6 = IPV6_TOKENS.get_or_init(|| {
        Regex::new(r"(?i)[0-9a-f:.]*:[0-9a-f:.]*").expect("constant IPv6 token regex")
    });
    // IPv6 first: an IPv4-mapped address must be removed as a single value.
    let text = ipv6.replace_all(text, |caps: &regex::Captures<'_>| {
        redact_ipv6_token(&caps[0])
    });
    addresses.replace_all(&text, "[redacted]").into_owned()
}

fn redact_ipv6_token(token: &str) -> String {
    // Bound parser work too. An oversized colon/hex token is never useful
    // diagnostic text, and keeping a partial address would defeat redaction.
    if token.len() > 128 {
        return "[redacted]".to_owned();
    }
    let mut out = String::new();
    let mut start = 0;
    while start < token.len() {
        let matched = (start + 2..=token.len().min(start + 45))
            .rev()
            .find(|&end| token[start..end].parse::<Ipv6Addr>().is_ok());
        if let Some(end) = matched {
            out.push_str("[redacted]");
            start = end;
        } else {
            // Tokens contain ASCII only, so these byte indices are boundaries.
            out.push(char::from(token.as_bytes()[start]));
            start += 1;
        }
    }
    out
}

fn parse_filter(filter: Option<String>) -> Result<Targets, TorFailure> {
    let filter = filter.as_deref().unwrap_or(DEFAULT_FILTER);
    if filter.len() > 4096 {
        return Err(TorFailure::configuration("Tor log filter is too long"));
    }
    if filter.contains(['[', ']', '{', '}']) {
        return Err(TorFailure::configuration("Invalid Tor log filter"));
    }
    let targets: Targets = filter
        .parse()
        .map_err(|_| TorFailure::configuration("Invalid Tor log filter"))?;
    if targets.default_level() == Some(LevelFilter::TRACE)
        || targets.iter().any(|(_, level)| level == LevelFilter::TRACE)
    {
        return Err(TorFailure::configuration(
            "Trace-level Tor logging is not supported",
        ));
    }
    Ok(targets)
}

fn global_router() -> Result<Arc<Router>, TorFailure> {
    static ROUTER: OnceLock<Result<Arc<Router>, &'static str>> = OnceLock::new();
    // Keep the guard for the lifetime of the native library. Never weaken
    // Arti's default Sensitive/Redacted formatting, even in debug builds.
    static SAFE_LOGGING: OnceLock<safelog::Guard> = OnceLock::new();
    ROUTER
        .get_or_init(|| {
            let guard =
                safelog::enforce_safe_logging().map_err(|_| "Safe Tor logging is unavailable")?;
            let router = Arc::new(Router::new());
            tracing::subscriber::set_global_default(
                Registry::default().with(LogLayer(Arc::clone(&router))),
            )
            .map_err(|_| "A native tracing subscriber is already installed")?;
            let _ = SAFE_LOGGING.set(guard);
            Ok(router)
        })
        .clone()
        .map_err(TorFailure::configuration)
}

/// An exclusive process-wide capture. Opening another capture closes this one.
///
/// Storage is bounded to 1024 records plus one batch per outstanding reader. Prefer one reader; do not issue concurrent `next_batch` calls. Close to cancel pending reads; dropping an idle handle also disables capture.
#[frb(opaque)]
pub struct TorLogStream {
    capture: Arc<Capture>,
    receiver: AsyncMutex<mpsc::Receiver<TorLogRecord>>,
    router: Arc<Router>,
}

/// Install native diagnostics and return a capture before starting Tor.
///
/// Synchronous so the caller can register before `TorService.start`. `None` selects the documented default targets. Filters use `target=level` and a default level, not EnvFilter expressions. Trace and invalid filters fail without replacing an existing capture. Logging is opt-in in every build.
#[frb(sync)]
pub fn open_log_stream(filter: Option<String>) -> Result<TorLogStream, TorFailure> {
    let filter = parse_filter(filter)?;
    Ok(global_router()?.open(filter))
}

impl TorLogStream {
    /// Wait for at least one record and return up to 64 records. An empty batch means closed/replaced. Queue overflow appends a warning summary to the next batch; it does not require another event to arrive.
    pub async fn next_batch(&self) -> Vec<TorLogRecord> {
        let mut closed = self.capture.closed.subscribe();
        if *closed.borrow() {
            return Vec::new();
        }
        let mut receiver = self.receiver.lock().await;
        loop {
            let mut batch = Vec::with_capacity(BATCH_SIZE);
            tokio::select! {
                biased;
                _ = closed.changed() => return Vec::new(),
                _ = receiver.recv_many(&mut batch, BATCH_SIZE - 1) => {},
                _ = self.capture.wait_for_loss() => {}
            }
            let dropped = self.capture.pending_dropped.swap(0, Ordering::Relaxed);
            if dropped != 0 {
                batch.push(TorLogRecord {
                    level: TorLogLevel::Warn,
                    target: "onion::log".to_owned(),
                    message: format!("{dropped} Tor log records dropped"),
                });
            }
            if !batch.is_empty() {
                return batch;
            }
        }
    }

    /// Read counters without logging or consuming buffered records.
    #[frb(sync)]
    pub fn stats(&self) -> TorLogStats {
        TorLogStats {
            accepted: self.capture.accepted.load(Ordering::Relaxed),
            dropped: self.capture.dropped.load(Ordering::Relaxed),
            routing_dropped: self.router.routing_dropped.load(Ordering::Relaxed),
        }
    }

    /// Idempotently disable this capture and wake a pending batch read. Closing an older handle never closes its replacement.
    #[frb(sync)]
    pub fn close(&self) {
        self.capture.stop();
        let mut active = self.router.active.lock().unwrap_or_else(|p| p.into_inner());
        if active
            .as_ref()
            .is_some_and(|capture| Arc::ptr_eq(capture, &self.capture))
        {
            *active = None;
        }
    }
}

impl Drop for TorLogStream {
    fn drop(&mut self) {
        self.close();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::Duration;

    fn capture(filter: &str) -> (TorLogStream, impl Subscriber + Send + Sync) {
        let router = Arc::new(Router::new());
        let stream = router.open(parse_filter(Some(filter.to_owned())).expect("filter"));
        (stream, Registry::default().with(LogLayer(router)))
    }

    fn emit(subscriber: impl Subscriber + Send + Sync + 'static, action: impl FnOnce()) {
        tracing::subscriber::with_default(subscriber, action);
    }

    #[tokio::test]
    async fn records_levels_targets_messages_and_fields() {
        let (stream, subscriber) = capture("onion=debug,off");
        emit(subscriber, || {
            tracing::warn!(target: "onion::socks", attempt = 3, "circuit failed");
            tracing::error!(target: "onion", "failed");
            tracing::info!(target: "onion", "ready");
            tracing::debug!(target: "onion", "details");
        });
        let batch = stream.next_batch().await;
        assert_eq!(batch.len(), 4);
        assert_eq!(batch[0].level, TorLogLevel::Warn);
        assert_eq!(batch[0].target, "onion::socks");
        assert!(batch[0].message.contains("circuit failed"));
        assert!(batch[0].message.contains("attempt=3"));
        assert_eq!(batch[1].level, TorLogLevel::Error);
        assert_eq!(batch[2].level, TorLogLevel::Info);
        assert_eq!(batch[3].level, TorLogLevel::Debug);
        assert_eq!(stream.stats().accepted, 4);
    }

    #[tokio::test]
    async fn filters_targets_and_levels_before_formatting() {
        struct MustNotFormat;
        impl fmt::Debug for MustNotFormat {
            fn fmt(&self, _: &mut fmt::Formatter<'_>) -> fmt::Result {
                panic!("filtered event formatted")
            }
        }
        let (stream, subscriber) = capture("tor_hsclient=debug,tor_proto=warn,off");
        emit(subscriber, || {
            tracing::info!(target: "other", value = ?MustNotFormat);
            tracing::debug!(target: "tor_proto", value = ?MustNotFormat);
            tracing::trace!(target: "tor_hsclient", value = ?MustNotFormat);
            tracing::debug!(target: "tor_hsclient::connect", "rendezvous");
            tracing::warn!(target: "tor_proto", "failed");
        });
        let batch = stream.next_batch().await;
        assert_eq!(batch.len(), 2);
        assert_eq!(batch[0].message, "rendezvous");
        assert_eq!(batch[1].message, "failed");
    }

    #[test]
    fn redacts_addresses_and_hex_identifiers_in_all_forms() {
        let onion = format!("{}.onion", "a".repeat(56));
        let txid = "f".repeat(64);
        for value in [
            onion.clone(),
            onion.to_uppercase(),
            "192.0.2.1".into(),
            "::1".into(),
            "2001:db8::1234".into(),
            "fe80::1".into(),
            "::ffff:192.0.2.1".into(),
            "2001:db8:0:0:0:0:0:1".into(),
            txid,
        ] {
            assert_eq!(
                redact(&format!("destination=[{value}]:443")),
                "destination=[[redacted]]:443",
                "{value}"
            );
        }
        assert_eq!(
            redact("failed: retry in 3s; fraction=0.25"),
            "failed: retry in 3s; fraction=0.25"
        );
        assert_eq!(redact("addr=2001:db8::1%eth0"), "addr=[redacted]%eth0");
    }

    #[tokio::test]
    async fn redacts_fields_and_bounds_unicode_and_control_characters() {
        let (stream, subscriber) = capture("debug");
        emit(subscriber, || {
            tracing::warn!(target: "onion", peer = "192.0.2.1", "failed\nretry\tsoon");
            tracing::info!(target: "onion", "{}", "é".repeat(1000));
            tracing::info!(target: "onion", "{}", "x".repeat(MAX_FORMAT_BYTES + 1));
            tracing::info!(target: "onion", secret = %safelog::sensitive("private destination"), "safe");
        });
        let batch = stream.next_batch().await;
        assert!(batch[0].message.contains("peer=[redacted]"));
        assert!(!batch[0].message.chars().any(char::is_control));
        assert_eq!(batch[1].message.chars().count(), MAX_MESSAGE_CHARS);
        assert_eq!(batch[2].message, "Tor log record omitted (oversized)");
        assert!(batch[3].message.contains("[scrubbed]"));
        assert!(!batch[3].message.contains("private destination"));
    }

    #[tokio::test]
    async fn overflow_is_bounded_counted_and_reported_without_another_event() {
        let (stream, _) = capture("debug");
        for _ in 0..CAPACITY + 5 {
            stream.capture.push(|| TorLogRecord {
                level: TorLogLevel::Info,
                target: "onion".into(),
                message: "queued".into(),
            });
        }
        stream
            .capture
            .push(|| panic!("a full queue must not format another record"));
        assert_eq!(stream.stats().accepted, CAPACITY as u64);
        assert_eq!(stream.stats().dropped, 6);
        let batch = stream.next_batch().await;
        assert_eq!(batch.len(), BATCH_SIZE);
        assert_eq!(
            batch.last().expect("summary").message,
            "6 Tor log records dropped"
        );
        assert_eq!(stream.capture.pending_dropped.load(Ordering::Relaxed), 0);
    }

    #[tokio::test]
    async fn a_delayed_overflow_count_is_reported_after_the_queue_was_drained() {
        let (stream, _) = capture("debug");
        // A full-queue producer can be descheduled before incrementing its
        // loss counter while the consumer drains the queue in the meantime.
        stream.capture.dropped.store(1, Ordering::Relaxed);
        stream.capture.pending_dropped.store(1, Ordering::Relaxed);
        let batch = tokio::time::timeout(Duration::from_millis(100), stream.next_batch())
            .await
            .expect("a loss summary must not wait for a new Tor event");
        assert_eq!(batch.len(), 1);
        assert_eq!(batch[0].message, "1 Tor log records dropped");
    }

    #[tokio::test]
    async fn a_delayed_overflow_count_wakes_an_already_pending_read() {
        let (stream, _) = capture("debug");
        let stream = Arc::new(stream);
        let reader = Arc::clone(&stream);
        let task = tokio::spawn(async move { reader.next_batch().await });
        tokio::task::yield_now().await;
        // This is the accounting step of a producer that observed a full
        // queue before the reader drained it and began waiting again.
        stream.capture.record_drop();
        let batch = tokio::time::timeout(Duration::from_secs(1), task)
            .await
            .expect("loss accounting must wake the reader")
            .expect("read must not panic");
        assert_eq!(batch[0].message, "1 Tor log records dropped");
    }

    #[tokio::test]
    async fn replacing_a_capture_closes_the_old_one_and_changes_the_filter() {
        let router = Arc::new(Router::new());
        let old = router.open(parse_filter(Some("warn".into())).expect("filter"));
        let subscriber = Registry::default().with(LogLayer(Arc::clone(&router)));
        let dispatch = tracing::Dispatch::new(subscriber);
        tracing::dispatcher::with_default(&dispatch, || tracing::info!("filtered"));
        assert_eq!(old.stats().accepted, 0);
        let new = router.open(parse_filter(Some("info".into())).expect("filter"));
        assert!(old.next_batch().await.is_empty());
        old.close();
        tracing::dispatcher::with_default(&dispatch, || tracing::info!("accepted"));
        assert_eq!(new.next_batch().await[0].message, "accepted");
        assert_eq!(new.stats().accepted, 1);
    }

    #[tokio::test]
    async fn close_wakes_a_pending_read_and_is_idempotent() {
        let (stream, _) = capture("debug");
        let stream = Arc::new(stream);
        let reader = Arc::clone(&stream);
        let task = tokio::spawn(async move { reader.next_batch().await });
        tokio::task::yield_now().await;
        stream.close();
        stream.close();
        assert!(tokio::time::timeout(Duration::from_secs(1), task)
            .await
            .expect("read must wake")
            .expect("read must not panic")
            .is_empty());
        assert!(stream.router.capture().is_none());
    }

    #[test]
    fn contention_drops_instead_of_blocking() {
        let router = Arc::new(Router::new());
        let stream = router.open(parse_filter(None).expect("filter"));
        let _held = router.active.lock().expect("lock");
        assert!(router.capture().is_none());
        assert_eq!(stream.stats().routing_dropped, 1);
        // Release before stream's Drop, which unregisters itself.
        drop(_held);
    }

    #[test]
    fn invalid_and_trace_filters_fail_without_echoing_user_input() {
        assert!(parse_filter(None).is_ok());
        for filter in [
            "trace",
            "onion=trace",
            "secret=bogus",
            "onion[secret]=debug",
        ] {
            let failure = parse_filter(Some(filter.into())).expect_err("reject filter");
            assert!(!failure.log_message.contains("secret"));
        }
    }
}
