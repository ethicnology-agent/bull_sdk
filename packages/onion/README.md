# onion

Embedded Tor client and loopback SOCKS5 proxy for Bull Bitcoin Mobile, built on
[Arti](https://gitlab.torproject.org/tpo/core/arti).

> **This is not an official Tor Project product.**
> Tor is a trademark of The Tor Project; all rights reserved — <https://torproject.org>.
> This software is not endorsed or sponsored by, or affiliated with, the Tor Project.
> It is a third-party integration that connects to the Tor network.

## Status

The Rust implementation, flutter_rust_bridge bindings, and mobile Snowflake
transport are complete. The package is consumed through
`package:bull_sdk/onion.dart`; its hermetic Rust suite exercises the lifecycle,
bridge configuration, and SOCKS protocol without a device attached.

## Why this exists

It replaces `github.com/Foundation-Devices/tor`, which the app currently
depends on. That package works, but:

- It is pinned to **arti 1.7.0** (October 2025) while upstream is on **2.5.0**.
  Its two commits in the past year could not keep pace with arti's monthly
  releases, and arti's own README warns that an integration which is not kept
  current "might stop working entirely".
- Its Rust wrapper reduces the whole of `BootstrapStatus` to a single `bool`
  captured once at startup. Everything arti knows about *why* it is stuck —
  including whether the connection is being filtered — is computed and then
  discarded at the FFI boundary. The failure resurfaces later as an
  unattributable RecoverBull transport error.
- `tor_client_bootstrap` reconstructs a `Box` from the client pointer and never
  leaks it back, so the pointer Dart keeps is dangling afterwards. Not
  currently triggered — nothing calls `setClientDormant` — but it is armed.

## Design decisions

**No dependency on the `arti` crate.** Since arti 2.0.0 every API in that crate
is marked experimental and "likely to get moved into other crates or removed".
Depending on `arti::proxy::run_proxy` is what made the previous wrapper
expensive to upgrade. We speak SOCKS5 ourselves via `tor-socksproto`, a normal
non-experimental crate, and keep `arti-client` as the only high-level
dependency.

**The SOCKS proxy is load-bearing, not general-purpose.** RecoverBull's Dart HTTP client already accepts a SOCKS5 endpoint. Binding `TorClient::connect` directly would require a separate HTTP transport over Arti streams. The proxy defaults to `SocksPolicy.any`; hosts can select `SocksPolicy.onionOnly` to reject clearnet and IP destinations at the local SOCKS boundary.

**`native-tls`, not `rustls`.** The bull_sdk aggregate already links both `ring`
and `aws-lc-rs` transitively, which makes rustls 0.23 panic when it
auto-selects a provider (see the pin in `lwk-dart/rust/Cargo.toml`). arti's
default is native-tls and `openssl-sys` is already in the aggregate lock.

**`static` feature.** Vendors OpenSSL and SQLite. Required on Android, which
has neither. Upstream marks it non-additive, so it is set here rather than left
to a consumer to remember.

**Nothing from `arti_client` crosses the public API.** Every exported type is
defined in this crate, so an upstream change is absorbed here instead of
rippling into the app, and the Dart side can switch exhaustively.

**Snowflake is native and unmanaged.** Android and iOS use the precompiled
IPtProxy 5.6.0 mobile library. It binds a local SOCKS5 listener; Arti's
`tor-ptmgr` connects to that listener as an unmanaged transport and never tries
to launch a subprocess. Native process-wide leases keep one listener alive
while multiple Flutter engines use it. The Android AAR and both iOS binary
slices are SHA-256 verified during every native build. See
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for provenance and licensing.

**Direct and Snowflake clients are separate.** `TorService::start()` remains
the direct path. For Snowflake, acquire `SnowflakeTransport`, pass its port to
`TorService::start_with_snowflake()`, and release the native lease after the Tor
service stops. Selecting Snowflake does not prove it connected;
`TorStatus::ready_for_traffic` must also be true before the UI says it is
connected through Snowflake.

**Every SOCKS session has circuit isolation.** The initial listener and each
listener returned by `TorService::open_session()` use a distinct
`TorClient::isolated_client()`. Arti guarantees that streams from two such
clients never share circuits, including hidden-service directory,
introduction, and rendezvous circuits. Sessions still share the root
configuration, directory state, guards, channels, transport, and observable
process/network timing; this is unlinkability between application streams, not
protection from a global observer. Stopping one session leaves the others
running. Stopping or dropping `TorService` stops every registered session.

## Snowflake transport events

`SnowflakeTransport.readEvents(afterSequence: cursor)` reads a process-wide native history on Android and iOS. It does not require a native log capture or a transport lease. Each reader keeps its own cursor; reads never consume another reader's events. No timer or background Dart subscription is installed.

```dart
var cursor = 0; // Keep in memory; reset after a process restart.
final batch = await SnowflakeTransport.readEvents(afterSequence: cursor);
cursor = batch.latestSequence;
for (final event in batch.events) {
  // event.kind, event.generation, event.elapsedMs, event.hasError
}
// batch.dropped counts records overwritten since this reader's cursor.
```

The native ring holds at most 64 records. Every record has a process-local sequence, a controller-attempt generation and monotonic milliseconds since that attempt began. A late callback retains its original generation even after a new controller starts. A future or negative cursor is rejected; callers must not persist cursors across process restarts. Returned event lists are immutable.

`starting`, `listening`, `startFailed` and `released` describe local controller lifecycle. `listening` only means that a local SOCKS port was bound; `released` means that the last lease requested teardown. IPtProxy's `connected` means a connection to a Snowflake proxy succeeded. `transportError` reports an error during discovery or on an established WebRTC connection, and `connectionStopped` can describe one connection stopping while the local listener remains available. Neither callback proves Arti has bootstrapped, nor should either trigger an unconditional core restart. Continue to use `TorStatus.readyForTraffic` for Tor readiness.

The callback semantics were checked against [IPtProxy 5.6.0's controller source](https://github.com/tladesignz/IPtProxy/blob/5d9cb01547d507f97f205076e61353de7881c8bc/IPtProxy.go/controller.go) on 2026-10-23. Native error objects, messages, transport names and addresses are not forwarded. `hasError` only indicates whether the callback carried an error. Native logging and unsafe logging remain disabled. These records stay in memory unless the host deliberately exports them; timing and event ordering still reveal connection activity.

Run the hermetic JVM history checks from this package (JDK 17 or newer):

```sh
classes=$(mktemp -d)
javac --release 17 -d "$classes" android/src/main/java/com/bullbitcoin/onion/SnowflakeEventBuffer.java android/src/test/java/com/bullbitcoin/onion/SnowflakeEventBufferTest.java
java -cp "$classes" com.bullbitcoin.onion.SnowflakeEventBufferTest
rm -r "$classes"
```

## Mobile plugin checks

The example has device checks for native log redaction, isolated connection histories and the real Snowflake method channel. They exercise plugin registration and FFI without bootstrapping Tor or contacting a key server. With the pinned Flutter SDK, build only the connected device's ABI; splitting the APK is necessary to exclude the other native ABI slices carried by IPtProxy's AAR.

```sh
cd example
fvm flutter build apk --debug --target-platform android-arm64 --split-per-abi --target integration_test/diagnostics_integration_test.dart
fvm flutter drive -d DEVICE_SERIAL --use-application-binary=build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk --driver=test_driver/integration_test.dart --target=integration_test/diagnostics_integration_test.dart
```

These checks passed on a physical Pixel 5 on 2026-10-23 with Flutter 3.44.9, Rust 1.95.0 and IPtProxy 5.6.0. The debug APK was verified to contain only `arm64-v8a` libraries. This validates the Android diagnostic plumbing; it does not establish live Tor reliability or validate the iOS build.

## Per-session connection diagnostics

`TorService.connectionEvents(afterSequence: cursor)` exposes the default listener's history. Each `TorSession.connectionEvents` has an independent history and anonymous attempt IDs. Both APIs work without enabling textual native logs and remain readable after `stop()` while the handle is retained.

```dart
var cursor = BigInt.zero; // Belongs to this session, not the process.
final batch = await session.connectionEvents(afterSequence: cursor);
cursor = batch.latestSequence;
for (final event in batch.events) {
  // event.attemptId, event.elapsedMs, event.kind, event.failure
}
```

Every accepted local socket records `accepted`. A permitted CONNECT records `connecting`, followed by `connected` if Arti opened a stream and `closed` when both relay directions reach EOF. `failed` carries a finite `ConnectionFailureKind`; `cancelled` means the Rust task was dropped before another terminal milestone, including session shutdown. The local 64-connection limit also produces a failure event. Milliseconds are monotonic from socket acceptance, so the difference between `connecting` and a subsequent milestone measures that connection attempt. Neither a Tor stream nor a Snowflake connection establishes TLS or application readiness.

The binding distinguishes local handshake errors/timeouts, policy refusals, its configurable connection deadline, bootstrap requirements, directory/path/circuit failures, onion descriptor/introduction/connection failures, missing or incorrect onion client authentication, invalid onion addresses, and remote connection/resolution failures. Unmapped Arti kinds become `otherTorFailure`; the category preserves Arti's classification and is not a definitive diagnosis of the remote service. Authentication diagnostics do not add an API to configure onion-service client keys. The mapping was checked against the pinned [tor-error 0.47.0 ErrorKind](https://docs.rs/tor-error/0.47.0/tor_error/enum.ErrorKind.html) on 2026-10-23.

The history retains at most 64 events per session, uses pull snapshots with independent cursors, and reports overwritten events in `dropped`. It creates no extra worker, subscription or timer. Start each session's cursor at zero; never reuse a cursor from another session. A cursor beyond the latest sequence returns a configuration failure. Slow readers may lose intermediate or terminal milestones; these diagnostics do not constitute an authoritative list of active streams. Cancellation records from aborted child tasks can arrive shortly after `stop()` returns.

Attempt IDs identify local sockets, not wallet operations or HTTP requests: clients can reuse a connection or open several concurrently. No destination, port, credentials, payload, peer address or upstream error text is retained in these events. Activity timing still carries metadata. Closing a SOCKS client during an in-progress Arti connect does not add immediate cancellation; existing connection budgets and session shutdown still bound that work. These APIs supply observations; retry, route renewal and presentation decisions belong to the host.

SOCKS wire replies keep their existing RFC 1928 statuses. Rich causes travel through this separate API, avoiding Tor's extended reply bytes that some SOCKS consumers cannot decode. Hermetic tests cover actual local SOCKS exchanges, session separation, missing bootstrap, policy and unsupported-command refusals, handshake timeout, cancellation, bounded history and cursor loss. Run `cargo test --locked --offline` in `rust/`; after building the native library, `fvm flutter test test/native_connection_smoke.dart` checks real FFI serialization without bootstrap or external traffic. Live Tor success paths and mobile device validation are separate checks.

## What it provides

```rust
let svc = TorService::start(state_dir, cache_dir, 0, SocksPolicy::Any).await?;  // binds, does not bootstrap
let port = svc.socks_port();                                   // real bound port
let mut events = svc.status_stream();                          // progress + blockage
svc.bootstrap().await?;
let electrum = svc.open_session(0, SocksPolicy::Any).await?;                     // different circuits
let rtt = svc.probe("check.torproject.org", 443, timeout).await?;
electrum.stop().await;
svc.stop().await;
```

On Android and iOS, the equivalent Snowflake setup from Dart is:

```dart
final snowflakePort = await SnowflakeTransport.start();
final service = await TorService.startWithSnowflake(
  stateDir: stateDir,
  cacheDir: cacheDir,
  socksPort: 0,
  snowflakePort: snowflakePort,
);
try {
  await service.bootstrap();
} finally {
  await service.stop();
  await SnowflakeTransport.stop();
}
```

### Native Tor diagnostics

After `OnionCore.init()`, call `OnionLogs.start()` **before** creating a `TorService`. Registration is synchronous: startup events can already enter the native queue when `start` returns. Capture is opt-in and available in every build mode. This package never prints records, writes support logs, or sends diagnostics to Sentry; the host decides where each level belongs.

```dart
await OnionCore.init();
final logs = OnionLogs.start();
final subscription = logs.records.listen(
  (record) {
    // Route record.level, record.target and record.message through the host's
    // logger. Do not append destination addresses or raw foreign errors.
  },
  onError: (Object error, StackTrace trace) {
    // Handle a diagnostics-stream failure separately from Tor readiness.
  },
);

// Create and bootstrap TorService only after registering the capture.
// Keep the capture alive across the sessions whose failures you investigate.
// ...
final counters = logs.stats;
// accepted/dropped belong to this capture; routingDropped is process-wide.
// Compare counter snapshots to measure loss during a particular operation.
await subscription.cancel(); // stops capture and wakes a pending native read
logs.close(); // also safe when no subscription was created; idempotent
```

Each `TorLogRecord` contains the native severity (`error`, `warn`, `info`, `debug`), the Rust module target, and a single-line message with structured `key=value` fields. Messages have at most 512 Unicode characters and targets at most 128. Oversized formatting (more than 8192 bytes) produces a fixed omission message, so an address cut in half during formatting cannot leak into the result. Treat the text as developer detail: wording and targets can change with Arti; do not parse it for application behavior or show it as localized UI.

The default filter is:

```text
onion=debug,tor_hsclient=debug,tor_circmgr=info,tor_guardmgr=info,tor_dirmgr=info,arti_client=info,tor_proto=warn,warn
```

`tor_hsclient` covers hidden-service descriptor, introduction and rendezvous work; `tor_circmgr` covers circuit management; `tor_guardmgr` and `tor_dirmgr` help distinguish guard/directory failures from destination problems. A lower-level event is available only if Arti emitted it and the filter accepted it. Logging cannot manufacture an explanation for every SOCKS error.

Use `OnionLogs.start(filter: 'onion=debug,tor_hsclient=debug,warn')` to override the filter. Directives use module prefixes, with the longest matching prefix winning, and an optional default level (`off`, `error`, `warn`, `info`, `debug`). This is `tracing_subscriber::filter::Targets` syntax, **not** `EnvFilter`: span/field expressions and `trace` are rejected. Invalid filters produce a configuration `TorFailure` without echoing the supplied filter or replacing the active capture. Explicit `debug` on selected modules can help an investigation, but the host must decide how much to persist after measuring a real bootstrap.

**Bounded delivery and lifecycle.** Rust stores at most 1024 records. Dart pulls batches of at most 64 through one outstanding FFI read, instead of sending one isolate message per event. Pausing the single-subscription Dart stream stops further reads and retains at most one batch in Dart; there is no native forwarding task filling a paused isolate's mailbox. When the native queue fills, new events are dropped before formatting. `TorLogStats.dropped` counts them and a synthetic `onion::log` warning summarizes losses in the next batch, even if no further event arrives. `accepted` counts records queued, not records persisted by the host. `routingDropped` counts process-wide event/span routing lookups skipped on routing-lock contention; these are separate from queue overflow. Native event routing uses `try_lock` and `try_reserve`, never a blocking send or host callback. This bounds logging storage and per-event formatting input, not the total log volume over time; a slow consumer must expect gaps.

Only one capture is active per loaded Onion library, across all services, sessions and Flutter engines. Opening another capture closes the previous stream and replaces its filter. Closing an old handle never stops its replacement. The global subscriber is installed once and remains installed but inactive after the capture closes. If the host already installed a native `tracing` subscriber in this library, opening a capture returns a configuration failure rather than replacing it or panicking. Onion is excluded from the bull_sdk Cargo workspace. Android builds a separate `libonion.so`; the iOS pod instead force-loads `libonion.a` into its CocoaPods target. Dispatcher isolation on iOS depends on the final link and must be checked with the consuming Xcode build; do not infer it from the separate Cargo graphs. Hosts that share a dispatcher must coordinate subscriber ownership.

For Rust or lower-level Dart callers, `open_log_stream` / `openLogStream` returns a `TorLogStream` with `next_batch` / `nextBatch`, `stats` and `close`. Await one batch at a time; an empty batch means closed or replaced. Close before disposing a Dart opaque handle or waiting for a pending Rust read; dropping an idle Rust handle also stops capture. Dart callers should prefer `OnionLogs`, whose cancellation wakes pending reads immediately.

**Privacy.** The resolved Arti 0.47 graph uses `safelog` **0.10.0** (it is independently versioned). Its `Sensitive` values format as `[scrubbed]` by default. The capture retains an `enforce_safe_logging` guard and never disables safe logging. Before crossing FFI, an additional scrubber removes v3 `.onion` hosts (case-insensitively), IPv4/IPv6 addresses including IPv4-mapped IPv6, and 64-character hexadecimal identifiers. Redaction precedes the final message-length limit, and control characters become spaces. This does not make arbitrary foreign text or newly introduced fields safe: preserve upstream sensitive wrappers, review new logging call sites, never add wallet secrets/destinations/user input, and audit actual exports before enabling host persistence. No host reporting policy is implied by a native `error` level.

**Future wallet integration.** Initialize the library, register one capture, then start Tor; keep that capture across connection attempts. Use `TorStatus` for progress, `readyForTraffic` and blockage decisions, `probe` to distinguish Tor reachability from a failing application server, and separate `TorSession` handles for circuit isolation. Logs add the underlying diagnostic context; they do not prove readiness or force a new circuit. A possible support-log policy is warning persistence for native errors/warnings, selected `info` milestones for `onion`, `tor_hsclient` and `tor_circmgr`, and console-only routing for debug and other info events. Never escalate to Sentry merely because a Rust event is `error`. Persisted volume, cold-bootstrap behavior and mobile builds must be measured in the consuming wallet; they are not validated by the binding's hermetic tests.

To reproduce the hermetic checks, use Rust 1.95.0 (`rust/rust-toolchain.toml`) and the consumer-compatible Flutter SDK (verified here with Flutter 3.44.9 / Dart 3.12.2):

```sh
cd packages/onion/rust
cargo test --locked
cargo clippy --all-targets --locked -- -D warnings
cd ..
fvm flutter analyze --fatal-warnings --fatal-infos
fvm flutter test
# Linux only: cargo test above also builds this debug shared library.
fvm flutter test test/native_log_capture_smoke.dart
```

The explicit Linux smoke test loads `rust/target/debug/deps/libonion.so` (override with `ONION_NATIVE_LIBRARY`), creates an unbootstrapped client, provokes a local SOCKS protocol error, checks the redacted record across FFI, replaces the capture and cancels a pending native read. It makes no connection to the Tor network. It is separate from the default `*_test.dart` suite, which uses FRB's mock API and needs no native library. Android/iOS builds and real Tor-network behavior still require their own validation.

References checked 2026-10-23: [safelog 0.10.0](https://docs.rs/safelog/0.10.0/safelog/), [Targets filter](https://docs.rs/tracing-subscriber/0.3.23/tracing_subscriber/filter/struct.Targets.html), and the exact crate sources resolved in `rust/Cargo.lock`.

### Status is not monotonic

arti documents that a client can become *less* bootstrapped over time — when
connectivity drops, or when its directory information expires. Consumers must
treat each `TorStatus` as the current truth rather than latching the first
`ready_for_traffic`. This is why the status is a stream and not a one-shot
boolean.

### Stage text

`TorStatus::stage` carries arti's own one-line description of the snapshot
(the `Display` of `BootstrapStatus`), for example `36%: connecting
successfully; directory is fetching authority certificates (0/9)`, or
`Stuck at …` followed by the blockage while arti believes it is stuck. arti designs that string for humans,
not parsers, and its wording can change between releases: show it as
diagnostic detail or log it, but act on `fraction`, `ready_for_traffic` and
`blockage`. It is not localized, and it is empty once the service has stopped.

### Blockage kinds

`TorStatus::blockage` carries the diagnostic the old wrapper threw away:

| Kind | Meaning |
|---|---|
| `NotStarted` | Bootstrap not requested yet. Never show this to a user. |
| `Offline` | No TCP connectivity at all. |
| `Filtering` | TCP works, the Tor handshake does not. **The censorship signature.** |
| `CantReachTor` | Some other problem reaching the network. |
| `ClockSkewed` | Device clock breaks certificate validation. |
| `CantBootstrap` | Directory could not be assembled. |
| `Other` | A kind added upstream after this mapping was written. |

`BlockageKind::suggests_censorship()` is **advisory**. arti describes
`blocked()` as best-effort and warns it "may declare that Arti is stuck for
reasons that are incorrect". Use it to *offer* circumvention; never assert to
the user that they are being censored.

`NotStarted` deserves its own note: it is arti reporting our own deliberate
`BootstrapBehavior::Manual` back to us, and it is present the entire time
between `start()` and `bootstrap()`. `is_user_visible()` exists to filter it.

### The probe is the canary

`ready_for_traffic` means "a request can be started", not "a request
succeeded". `probe()` opens and closes a real circuit through
`TorClient::connect`, bypassing both the SOCKS listener and the app's servers.
That is what separates the two failures the app currently cannot tell apart:

| Probe | RecoverBull | Conclusion |
|---|---|---|
| ok | ok | healthy |
| ok | fails | **the server** — Tor is fine |
| fails | fails | **Tor** — read `blockage` for why |

### SOCKS scope

`CONNECT` to `.onion` hosts only. Clearnet and IP targets are answered with
`NOT_ALLOWED`; the embedded proxy exists for Bull Bitcoin's hidden-service
traffic, not as a general-purpose Tor proxy for other local processes. A
maximum of 64 connections, a 10-second handshake deadline, and a 60-second Tor
connection deadline per session bound local resource use. Session ports are
loopback-only and distinct, but currently unauthenticated; callers must not log
or expose them, and native SOCKS credentials remain future hardening.

`RESOLVE`/`RESOLVE_PTR` are recognized by the protocol parser and answered with
`COMMAND_NOT_SUPPORTED`: nothing in the app uses them, and a subtly wrong
name-resolution path inside an anonymity system is worse than a clean refusal.
`BIND`/`UDP_ASSOCIATE` are rejected by `tor-socksproto` before a request object
exists, so the connection is closed without a SOCKS reply — the same behaviour
as arti's own proxy.

## Testing

```sh
cargo test --all-targets --locked                             # hermetic, no network
cargo test --locked --test live_network -- --ignored --nocapture # real Tor network
cargo clippy --all-targets --locked -- -D warnings
cargo fmt --check
fvm flutter analyze --fatal-warnings --fatal-infos
```

The live suite bootstraps for real, watches progress on the status stream,
runs the probe against a working and a bogus destination, and drives an actual
SOCKS5 `CONNECT` end to end — reading a live HTTP response back through the
tunnel.

## Why this is a standalone package, not part of the bull_sdk aggregate

It was going to be a sub-crate of `rust_lib_bull_sdk`, like `lwk` and `boltz`.
Cargo refuses:

```
package `libsqlite3-sys` links to the native library `sqlite3`, but it
conflicts with a previous package which links to `sqlite3` as well
```

- `ark_wallet` -> `ark-client 0.7.0` -> `sqlx 0.8` -> `libsqlite3-sys 0.30`
- `onion` -> `arti-client 0.47` -> `tor-dirmgr` -> `rusqlite >=0.36 <0.41` ->
  `libsqlite3-sys 0.37`

Only one package in a graph may declare `links = "sqlite3"`. `rusqlite` is a
hard, non-optional dependency of `tor-dirmgr` — no feature turns it off — so
there is no way to make arti fit alongside sqlx 0.8.

This unblocks itself upstream: `sqlx-sqlite 0.9.0` (2026-05-21) accepts
`libsqlite3-sys >=0.30.1 <0.38.0`, which covers 0.34. The day `ark-client`
moves from `sqlx ^0.8` to `^0.9`, the two can share a graph again. Until then
the split is forced, not chosen.

The consolation is that the forced shape is the better one anyway: `onion`
ships its own `.so` (like `bdk_dart` and `payjoin` already do in the app),
keeps its own release profile instead of joining a 661-crate fat-LTO link
unit, and can follow arti's monthly releases without waiting for the
aggregate.

## Snowflake limitations

- The bridge lines are copied verbatim from Tor Browser's
  `projects/tor-expert-bundle/pt_config.json` (re-checked 2026-10-07). Updating
  Arti or IPtProxy requires reviewing these values against the current official
  Snowflake configuration.
- Arti has no BridgeDB/moat client. A future dynamic bridge distribution flow
  would require a separate integration.
- Changing between direct and Snowflake transport recreates the client; it is
  not a live `TorClient::reconfigure()` operation.
- IPtProxy bundles GPL-3.0 Lyrebird even though this package invokes only
  Snowflake. Production distribution requires legal approval and compliance.

## Known upstream hazard

`arti-client` documents that it "can call `exit(1)` and terminate your process
if it receives a network consensus document telling it that it is obsolete"
(tracked as arti issue #1932). For a wallet this is a real operational risk and
an argument for keeping the dependency current.

## Binding shape

Running `flutter_rust_bridge_codegen generate` (2.12.0, the version bull_sdk
pins) produces the complete Dart API from the Rust surface:

```dart
abstract class TorService implements RustOpaqueInterface {
  static Future<TorService> start({required String stateDir,
                                   required String cacheDir,
                                   required int socksPort});
  static Future<TorService> startWithSnowflake({required String stateDir,
                                                 required String cacheDir,
                                                 required int socksPort,
                                                 required int snowflakePort});
  Future<TorSession> openSession({required int socksPort});
  Future<void> bootstrap();
  Future<TorStatus> status();
  Stream<TorStatus> watchStatus();
  Future<int> probe({required String host, required int port,
                     required int timeoutMs});
  Future<void> setDormant({required bool dormant});
  Future<int> socksPort();
  Future<void> stop();
}

abstract class TorSession implements RustOpaqueInterface {
  Future<int> socksPort();
  Future<bool> proxyIsAlive();
  Future<void> stop();
}
```

`TorStatus` and `Blockage` came out as Dart value classes with `==`/`hashCode`,
`BlockageKind` and `TorFailureKind` as real Dart enums, `TorFailure` as a class
`implements FrbException`, and every doc comment was carried across verbatim.
Rust `snake_case` became Dart `camelCase`; `async fn` became `Future`.
Hand-written Rust binding code: **zero lines**.

The generator is syntactic, not semantic, so four things had to be written in
shapes it recognises. None of them are annotations on business logic; all are
recorded at their call sites:

| Symptom | Cause | Fix |
|---|---|---|
| `TorResult`, `TorResultDuration`, `TorResultSelf` exported as opaque handles | FRB pattern-matches the *written* type; a `type TorResult<T>` alias hides `Result` | spell `Result<T, TorFailure>` out in public signatures |
| `status_stream` skipped with "error during generation" | no mapping for `impl Stream` | add `watch_status(sink: StreamSink<TorStatus>)`; `#[frb(ignore)]` on the Rust-only one |
| `Result<Duration, _>` would not compile | FRB maps `Duration` inbound via chrono but has no outbound conversion | milliseconds as `u32` across the boundary (`u64` would surface as `BigInt`) |
| `mod frb_generated;` injected above the inner attributes | codegen inserts at line 1, which Rust rejects | move it below; its own auto-comment admits the placement "may not be accurate" |

Three annotations total, all justified: `#[frb(ignore)]` on the Rust-only
stream helper, `#[frb(ignore)]` on the `impl Display` error constructors (no FFI
mapping, and they are internal builders), and `#[frb(sync)]` on the three pure
predicates so a `matches!` does not become an async round-trip to the Rust
isolate.

Maintenance consequence: adding a method to `TorService` means writing the Rust
method and re-running the generator. Nothing else.

## Probe cancellation and scope

Stopping `TorService` cancels a pending `probe` wait with `notRunning`, drops the connection future and releases the probe's client reference. A caller deadline remains `timeout`; native connection failures remain `connect`. Cancelling that wait does not guarantee that all shared Arti background work has stopped. An individual probe still uses its supplied deadline; operation-scoped cancellation without stopping the service is not exposed.

A service probe uses the root client. SOCKS sessions use isolated clients whose streams cannot share circuits with the root. A repeated probe can measure reuse in its own context, but does not establish that a new wallet session has a ready circuit or that its HTTP operation will succeed. Prefer measuring the actual operation over adding an automatic preflight probe.

## Opt-in live circuit experiment

The example's `integration_test/live_tor_probe_test.dart` performs cold direct and Snowflake bootstraps, then opens and closes two circuits to the public RecoverBull service. It sends no wallet, password, recovery key or application request. A successful circuit is not an HTTP health check or a completed recovery. The second probe measures reuse inside the same client, not a new isolated session. Network-dependent failures are expected to remain failures in the test report.

From `packages/onion/example`, build a debug APK for the attached arm64 device and run the integration driver:

```sh
fvm flutter build apk --debug --target-platform android-arm64 --split-per-abi --target integration_test/live_tor_probe_test.dart
fvm flutter drive --debug --driver test_driver/integration_test.dart --target integration_test/live_tor_probe_test.dart --use-application-binary=build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk -d DEVICE_SERIAL --timeout=600
```

To investigate Snowflake separately, add `--dart-define=SNOWFLAKE_ONLY=true` to the build. The experiment prints elapsed times, failure kinds, typed Arti readiness/blockage and bounded native event metadata. It does not print foreign exception messages or destinations. The SDK's native bootstrap deadline still applies; the test's outer deadline does not extend it. Compare generations when interpreting callbacks after shutdown, and retain unsuccessful runs alongside successful ones.
