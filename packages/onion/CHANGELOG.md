## Unreleased

- Optimize the Tor release build for throughput instead of size, retaining LTO, stripping and one codegen unit. Debug builds are unchanged.

- Expose startup workload settings to skip speculative exit/DNS circuits for onion-only hosts while preserving Arti defaults for existing callers.

## 0.2.0

- Add physical-device diagnostic checks and a prebuilt-APK driver for native log redaction, isolated connection history and the Snowflake method channel.

- Expose bounded per-session SOCKS connection histories with anonymous attempt IDs, monotonic timing and typed local/Arti failure causes; preserve compatible SOCKS wire replies and expose cancellation on task teardown.

- Name the Snowflake error milestone `transportError` because IPtProxy also emits it after a proxy connection was established.
- Expose typed native Snowflake lifecycle and connection events on Android and iOS through an independently readable, bounded history with generation IDs, timing and loss counts; never forward native error messages.

- Expose opt-in native Arti diagnostics through `OnionLogs` and the lower-level `TorLogStream`, with synchronous registration before Tor startup.
- Pull bounded batches across FFI, stop native reads while Dart is paused, and expose queue-loss and routing-contention counters.
- Preserve safe logging and redact onion hosts, IP addresses and 64-character hexadecimal identifiers before delivery; bound message formatting and reject trace filters.
- Support capture replacement, explicit close and cancellation without installing multiple native subscribers; document lifecycle, filters, privacy limits and future host integration.

## 0.1.0

- Add an embedded Arti client and loopback SOCKS5 proxy for `.onion` traffic.
- Expose bootstrap progress, blockage diagnostics, reachability probes, dormancy, and deterministic shutdown through flutter_rust_bridge.
- Add a checksum-verified IPtProxy 5.5.1 Snowflake transport on Android and iOS, with unmanaged Arti bridge configuration and process-wide native leases.
- Add `TorSession` listeners backed by Arti isolated clients so application streams from separate sessions never share circuits.
- Support Android, iOS, Linux, macOS, and Windows through Cargokit.
