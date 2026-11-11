# bull_sdk

Unified flutter_rust_bridge bindings for Bitcoin and Liquid wallet operations.

## Why

Over the past years, we contributed to the open source community by creating flutter_rust_bridge bindings for several Bitcoin/Liquid libraries:

- [ark-wallet-dart](https://github.com/SatoshiPortal/ark-wallet-dart) — Ark protocol
- [bbqr-dart](https://github.com/SatoshiPortal/bbqr-dart) — Animated QR encoding
- [boltz-dart](https://github.com/SatoshiPortal/boltz-dart) — Boltz atomic swaps
- [lwk-dart](https://github.com/SatoshiPortal/lwk-dart) — Liquid Wallet Kit

Each of these packages works standalone and is used by other projects in the community.

However, our wallet app [Bull Bitcoin](https://github.com/SatoshiPortal/BULL) depends on all of them. This creates two problems:

1. **Build time** — Each package compiles its own native library (`.so`/`.dylib`). Building them all individually is slow, especially for Android where each targets 3 architectures.
2. **Binary size** — Shared Rust dependencies (bitcoin, secp256k1, tokio, openssl, etc.) are duplicated across each native library.

## Approach

`bull_sdk` is a single flutter_rust_bridge package that generates unified Dart bindings by scanning the Rust API of each sub-crate as external dependencies:

```yaml
# flutter_rust_bridge.yaml
rust_input: crate::api, ark_wallet::ark, bbqr, dart_bbqr::api, boltz::api, lwk::api
```

This produces **one native library** containing all the Rust code, with **one FRB dispatcher** handling all FFI calls.

### Key constraints

- **Standalone packages are preserved** — Each sub-crate remains a fully functional standalone flutter_rust_bridge package. The community can keep using `boltz-dart` or `lwk-dart` independently.
- **Sub-crate `frb_generated` is cfg-gated** — When used as a dependency of `bull_sdk`, each sub-crate's `frb_generated.rs` is disabled via `#[cfg(not(feature = "bull_sdk"))]` to avoid duplicate trait implementations. `bull_sdk` provides its own unified `frb_generated.rs`.
- **Mirror types for data-variant enums** — Rust enums with data (like `TxFee`, `ArkTransaction`) become opaque when scanned as external crate types. We use `#[frb(mirror)]` to generate proper sealed Dart classes.
- **Post-processing** — After FRB codegen, `fix_frb_generated.sh` patches the generated Rust code to wrap error types in `FrbWrapper` and convert mirrored types via `.into()`.

## Structure

```
bull-sdk/
├── Cargo.toml                          # Cargo workspace
├── packages/
│   ├── bull_sdk/                       # Unified FRB package (single native library)
│   │   ├── flutter_rust_bridge.yaml
│   │   ├── fix_frb_generated.sh        # Post-processing script
│   │   ├── rust/                       # Bridge crate
│   │   └── lib/
│   │       ├── bull_sdk.dart           # BullSdk.init()
│   │       ├── bbqr.dart               # BBQr types
│   │       ├── bitbox.dart             # BitBox types
│   │       ├── boltz.dart              # Boltz swap types
│   │       ├── lwk.dart                # Liquid Wallet Kit types
│   │       ├── bdk.dart                # Re-exports the SDK-pinned bdk_dart
│   │       └── main.dart               # flutter_rust_bridge template demo app
│   ├── bbqr/                           # git submodule → SatoshiPortal/bbqr-dart
│   ├── bitbox/                         # git submodule → SatoshiPortal/bitbox-dart
│   ├── boltz/                          # git submodule → SatoshiPortal/boltz-dart
│   ├── lwk/                            # git submodule → SatoshiPortal/lwk-dart
│   ├── bitbox-transport/               # Pure Dart — BitBox transport
│   ├── boltz-stream/                   # Pure Dart — BoltzWebSocket (depends on bull_sdk)
│   └── satoshifier/                    # Pure Dart — payment-string parsers
```

The submodules are not a build input: cargo resolves each crate from the `rev`
pinned in `packages/bull_sdk/rust/Cargo.toml`, which is the source of truth, and
no Dart path dependency points into `packages/`. Keep a submodule pointer equal
to its cargo `rev` so the checked-out source matches what actually builds.

## Regenerating bindings

```bash
cd packages/bull_sdk
flutter_rust_bridge_codegen generate
bash fix_frb_generated.sh
cargo check -p rust_lib_bull_sdk
```

Always run `fix_frb_generated.sh` after codegen — it patches error type wrapping and mirror type conversions that FRB cannot handle automatically for external crate types.

## Usage

```dart
import 'package:bull_sdk/bull_sdk.dart';
import 'package:bull_sdk/boltz.dart' as boltz;
import 'package:bull_sdk/lwk.dart' as lwk;
import 'package:bull_sdk/bbqr.dart' as bbqr;
import 'package:bull_sdk/ark.dart' as ark;

await BullSdk.init();
```

## Liquid regtest

The aggregate bindings include LWK's regtest network, seed-based descriptor/signing APIs and per-wallet regtest policy assets. Read the policy asset from the Elements node rather than treating it as Liquid testnet. Explicit `tcp://` Electrum transport is allowed only on regtest; mainnet and testnet retain TLS validation.

`Blockchain.test`, `Blockchain.broadcastTxBytes`, `Blockchain.broadcastSignedPset` and `batchBroadcast` require the concrete Liquid network. `Wallet.sync_` returns whether LWK applied an update. The obsolete SideSwap `Wallet.buildPayjoinTx` and `PayjoinTx` bindings are removed by the upstream LWK migration. Deploy the regenerated Dart bindings and native library together.

With Nigiri's Liquid RPC, faucet and Electrum listening on loopback ports 18884, 3001 and 50001, build the host library and run the explicit integration test:

```sh
cargo build --locked -p rust_lib_bull_sdk
cd packages/bull_sdk
fvm flutter test tool/liquid_regtest_test.dart
```

The test checks the node's network, creates two temporary wallets from in-memory random seeds, receives faucet funds, signs and broadcasts a transfer, verifies receipt and checks that a subsequent unchanged scan returns false. It never prints or persists the seeds and removes its wallet caches after execution.
