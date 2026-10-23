## 0.2.0

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
