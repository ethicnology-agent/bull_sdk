//! Bounded, destination-free diagnostics for each SOCKS session.

use std::collections::VecDeque;
use std::sync::{Arc, Mutex};
use std::time::Instant;

use tor_error::ErrorKind;

use super::error::TorFailure;

const CAPACITY: usize = 64;

/// Milestone of one accepted local SOCKS connection, not an HTTP request.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ConnectionEventKind {
    /// A local socket was accepted, before SOCKS negotiation.
    Accepted,
    /// A valid permitted CONNECT began its Arti connection attempt.
    Connecting,
    /// Arti opened a stream; this does not imply application-level success.
    Connected,
    /// Both directions of the relay reached EOF.
    Closed,
    /// The attempt ended with the accompanying failure category.
    Failed,
    /// The owning task was dropped before reaching a terminal milestone.
    Cancelled,
}

/// Safe diagnostic categories; no upstream error text or destination crosses FFI.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ConnectionFailureKind {
    /// The session already has 64 concurrent accepted connections.
    ConnectionLimit,
    /// The SOCKS handshake was invalid, disconnected or failed I/O.
    HandshakeFailed,
    /// The local SOCKS handshake exceeded ten seconds.
    HandshakeTimeout,
    /// The SOCKS command was not CONNECT.
    UnsupportedCommand,
    /// The configured destination policy rejected the request.
    PolicyDenied,
    /// The target could not be converted to a Tor address.
    InvalidTarget,
    /// The binding's connection budget expired.
    ConnectTimeout,
    /// Arti requires an explicit bootstrap before connecting.
    BootstrapRequired,
    /// Arti could not use or fetch a Tor directory.
    DirectoryUnavailable,
    /// Arti could not construct a suitable relay path.
    NoPath,
    /// Arti found no exit matching the requested destination.
    NoExit,
    /// The Tor circuit collapsed.
    CircuitCollapsed,
    /// A relay refused circuit construction or extension.
    CircuitRefused,
    /// Arti reported a remote network timeout.
    NetworkTimeout,
    /// No onion-service descriptor was found; the service may be down or unpublished.
    OnionServiceNotFound,
    /// A descriptor was found but introduction points could not reach the service.
    OnionServiceNotRunning,
    /// The onion service or Tor network prevented the connection.
    OnionServiceConnectionFailed,
    /// Arti reported a protocol violation involving the onion service.
    OnionServiceProtocolViolation,
    /// The onion service requires client authentication.
    OnionServiceMissingClientAuth,
    /// The onion service rejected the supplied client authentication.
    OnionServiceWrongClientAuth,
    /// The onion address failed validation.
    OnionServiceAddressInvalid,
    /// The remote hostname was not found.
    HostNotFound,
    /// Remote hostname resolution failed.
    NameResolutionFailed,
    /// The remote destination refused the connection.
    ConnectionRefused,
    /// Arti reported a closed, reset or failed remote stream.
    RemoteStreamFailed,
    /// Arti locally forbids this target address.
    ForbiddenTarget,
    /// Local SOCKS reply or bidirectional relay I/O failed.
    LocalIo,
    /// An Arti error kind has no explicit mapping in this binding.
    OtherTorFailure,
}

impl ConnectionFailureKind {
    pub(crate) fn from_arti(kind: ErrorKind) -> Self {
        match kind {
            ErrorKind::BootstrapRequired => Self::BootstrapRequired,
            ErrorKind::TorDirectoryError | ErrorKind::TorDirectoryUnusable => {
                Self::DirectoryUnavailable
            }
            ErrorKind::NoPath => Self::NoPath,
            ErrorKind::NoExit => Self::NoExit,
            ErrorKind::CircuitCollapse => Self::CircuitCollapsed,
            ErrorKind::CircuitRefused => Self::CircuitRefused,
            ErrorKind::RemoteNetworkTimeout => Self::NetworkTimeout,
            ErrorKind::OnionServiceNotFound => Self::OnionServiceNotFound,
            ErrorKind::OnionServiceNotRunning => Self::OnionServiceNotRunning,
            ErrorKind::OnionServiceConnectionFailed => Self::OnionServiceConnectionFailed,
            ErrorKind::OnionServiceProtocolViolation => Self::OnionServiceProtocolViolation,
            ErrorKind::OnionServiceMissingClientAuth => Self::OnionServiceMissingClientAuth,
            ErrorKind::OnionServiceWrongClientAuth => Self::OnionServiceWrongClientAuth,
            ErrorKind::OnionServiceAddressInvalid => Self::OnionServiceAddressInvalid,
            ErrorKind::RemoteHostNotFound => Self::HostNotFound,
            ErrorKind::RemoteHostResolutionFailed => Self::NameResolutionFailed,
            ErrorKind::RemoteConnectionRefused => Self::ConnectionRefused,
            ErrorKind::RemoteStreamClosed
            | ErrorKind::RemoteStreamReset
            | ErrorKind::RemoteStreamError => Self::RemoteStreamFailed,
            ErrorKind::InvalidStreamTarget => Self::InvalidTarget,
            ErrorKind::ForbiddenStreamTarget => Self::ForbiddenTarget,
            _ => Self::OtherTorFailure,
        }
    }
}

/// A safe milestone, correlated only within its owning session.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ConnectionEvent {
    /// Increasing sequence within this session.
    pub sequence: u64,
    /// Anonymous accepted-socket ID, unique only within this session.
    pub attempt_id: u64,
    /// Monotonic milliseconds since the local socket was accepted.
    pub elapsed_ms: u64,
    /// Current milestone for this attempt.
    pub kind: ConnectionEventKind,
    /// Present only on Failed events.
    pub failure: Option<ConnectionFailureKind>,
}

/// Snapshot of at most 64 events; reading does not consume other readers' history.
#[derive(Debug)]
pub struct ConnectionEventBatch {
    /// Recent events in increasing sequence order.
    pub events: Vec<ConnectionEvent>,
    /// Cursor to use for the next read.
    pub latest_sequence: u64,
    /// Events overwritten since the supplied cursor.
    pub dropped: u64,
}

struct HistoryState {
    events: VecDeque<ConnectionEvent>,
    sequence: u64,
    attempt_id: u64,
}

pub(crate) struct ConnectionHistory {
    state: Mutex<HistoryState>,
}

impl ConnectionHistory {
    pub(crate) fn new() -> Arc<Self> {
        Arc::new(Self {
            state: Mutex::new(HistoryState {
                events: VecDeque::with_capacity(CAPACITY),
                sequence: 0,
                attempt_id: 0,
            }),
        })
    }

    pub(crate) fn begin(self: &Arc<Self>) -> ConnectionAttempt {
        let mut state = self.state.lock().unwrap_or_else(|e| e.into_inner());
        state.attempt_id += 1;
        let attempt_id = state.attempt_id;
        Self::push(
            &mut state,
            attempt_id,
            0,
            ConnectionEventKind::Accepted,
            None,
        );
        ConnectionAttempt {
            history: Arc::clone(self),
            attempt_id,
            started_at: Instant::now(),
            finished: false,
        }
    }

    pub(crate) fn read(&self, after_sequence: u64) -> Result<ConnectionEventBatch, TorFailure> {
        let state = self.state.lock().unwrap_or_else(|e| e.into_inner());
        if after_sequence > state.sequence {
            return Err(TorFailure::configuration("invalid connection event cursor"));
        }
        let oldest = state
            .events
            .front()
            .map_or(state.sequence + 1, |e| e.sequence);
        Ok(ConnectionEventBatch {
            events: state
                .events
                .iter()
                .filter(|e| e.sequence > after_sequence)
                .cloned()
                .collect(),
            latest_sequence: state.sequence,
            dropped: oldest.saturating_sub(after_sequence + 1),
        })
    }

    fn push(
        state: &mut HistoryState,
        attempt_id: u64,
        elapsed_ms: u64,
        kind: ConnectionEventKind,
        failure: Option<ConnectionFailureKind>,
    ) {
        state.sequence += 1;
        if state.events.len() == CAPACITY {
            state.events.pop_front();
        }
        state.events.push_back(ConnectionEvent {
            sequence: state.sequence,
            attempt_id,
            elapsed_ms,
            kind,
            failure,
        });
    }
}

pub(crate) struct ConnectionAttempt {
    history: Arc<ConnectionHistory>,
    attempt_id: u64,
    started_at: Instant,
    finished: bool,
}

impl ConnectionAttempt {
    pub(crate) fn record(&self, kind: ConnectionEventKind) {
        self.push(kind, None);
    }

    pub(crate) fn fail(&mut self, failure: ConnectionFailureKind) {
        self.finish(ConnectionEventKind::Failed, Some(failure));
    }

    pub(crate) fn close(&mut self) {
        self.finish(ConnectionEventKind::Closed, None);
    }

    pub(crate) fn is_finished(&self) -> bool {
        self.finished
    }

    fn finish(&mut self, kind: ConnectionEventKind, failure: Option<ConnectionFailureKind>) {
        if !self.finished {
            self.push(kind, failure);
            self.finished = true;
        }
    }

    fn push(&self, kind: ConnectionEventKind, failure: Option<ConnectionFailureKind>) {
        let mut state = self.history.state.lock().unwrap_or_else(|e| e.into_inner());
        ConnectionHistory::push(
            &mut state,
            self.attempt_id,
            self.started_at.elapsed().as_millis().min(u64::MAX as u128) as u64,
            kind,
            failure,
        );
    }
}

impl Drop for ConnectionAttempt {
    fn drop(&mut self) {
        self.finish(ConnectionEventKind::Cancelled, None);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bounds_history_reports_loss_and_preserves_independent_cursors() {
        let history = ConnectionHistory::new();
        assert!(history.read(0).expect("read").events.is_empty());
        for _ in 0..40 {
            history.begin().close();
        }
        let batch = history.read(0).expect("read");
        assert_eq!(batch.events.len(), 64);
        assert_eq!(batch.latest_sequence, 80);
        assert_eq!(batch.dropped, 16);
        assert_eq!(history.read(16).expect("read").dropped, 0);
        assert_eq!(history.read(79).expect("read").events.len(), 1);
        assert_eq!(history.read(0).expect("read again").events, batch.events);
        assert!(history.read(80).expect("read").events.is_empty());
        assert!(history.read(81).is_err());
    }

    #[test]
    fn abandoned_attempts_are_cancelled_and_failure_is_terminal() {
        let history = ConnectionHistory::new();
        drop(history.begin());
        let mut attempt = history.begin();
        attempt.record(ConnectionEventKind::Connecting);
        attempt.fail(ConnectionFailureKind::ConnectTimeout);
        attempt.fail(ConnectionFailureKind::LocalIo);
        drop(attempt);
        let events = history.read(0).expect("read").events;
        assert_eq!(events.len(), 5);
        assert_eq!(events[1].kind, ConnectionEventKind::Cancelled);
        assert_eq!(events[1].attempt_id, 1);
        assert_eq!(events[4].attempt_id, 2);
        assert_eq!(
            events[4].failure,
            Some(ConnectionFailureKind::ConnectTimeout)
        );
    }

    #[test]
    fn preserves_onion_failure_distinctions_and_defaults_unknown_kinds() {
        for (arti, expected) in [
            (
                ErrorKind::OnionServiceNotFound,
                ConnectionFailureKind::OnionServiceNotFound,
            ),
            (
                ErrorKind::OnionServiceNotRunning,
                ConnectionFailureKind::OnionServiceNotRunning,
            ),
            (
                ErrorKind::OnionServiceConnectionFailed,
                ConnectionFailureKind::OnionServiceConnectionFailed,
            ),
            (
                ErrorKind::OnionServiceMissingClientAuth,
                ConnectionFailureKind::OnionServiceMissingClientAuth,
            ),
            (
                ErrorKind::OnionServiceWrongClientAuth,
                ConnectionFailureKind::OnionServiceWrongClientAuth,
            ),
            (
                ErrorKind::OnionServiceAddressInvalid,
                ConnectionFailureKind::OnionServiceAddressInvalid,
            ),
            (ErrorKind::Other, ConnectionFailureKind::OtherTorFailure),
        ] {
            assert_eq!(ConnectionFailureKind::from_arti(arti), expected);
        }
    }
}
