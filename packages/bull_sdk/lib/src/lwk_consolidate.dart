import 'package:bull_sdk/lwk.dart';

/// Hand-maintained port of `lwk-dart`'s `lib/src/consolidate.dart` helpers.
///
/// bull_sdk generates its own independent copy of the `Wallet`/`Blockchain`
/// FRB types from lwk's Rust source (see `flutter_rust_bridge.yaml`'s
/// `rust_input`) — a second, separate native-library binding, not the same
/// Dart classes `lwk-dart`'s own generated package produces. That means
/// `lwk-dart`'s hand-written Dart helpers, written against ITS types, cannot
/// be imported and called with a `bull_sdk` `Wallet` instance; the same
/// architectural reason the boltz-dart helpers were reimplemented here
/// instead of imported. This file re-derives the same small amount of
/// orchestration logic against bull_sdk's own generated `Wallet`/`Blockchain`
/// — every primitive it calls (`Wallet.consolidate`, `Wallet.signTx`,
/// `Blockchain.broadcastSignedPset`, `getLbtcAssetId`/`getLtestAssetId`)
/// already exists in bull_sdk's generated bindings, so no Rust/FFI changes
/// are needed to keep this in sync with lwk-dart's own convenience layer.

/// Number of confirmed L-BTC UTXOs in the wallet.
///
/// Takes [network] rather than a raw asset-id string so callers can't typo or
/// mismatch mainnet/testnet asset IDs — the correct one is looked up
/// internally via [getLbtcAssetId]/[getLtestAssetId], or from the wallet on
/// regtest.
Future<int> confirmedLbtcUtxoCount(
  Wallet wallet, {
  required LiquidNetwork network,
}) async {
  final lbtcAssetId = switch (network) {
    LiquidNetwork.mainnet => getLbtcAssetId(),
    LiquidNetwork.testnet => getLtestAssetId(),
    // A regtest policy asset depends on the node, so ask the wallet.
    LiquidNetwork.regtest => await wallet.policyAsset(),
  };
  final utxos = await wallet.utxos();
  return utxos
      .where((u) => u.unblinded.asset == lbtcAssetId && u.height != null)
      .length;
}

Future<List<String>> batchSign(
  Wallet wallet, {
  required List<String> psets,
  required LiquidNetwork network,
  required String mnemonic,
}) async {
  final signed = <String>[];
  for (final p in psets) {
    signed.add(
      await wallet.signTx(network: network, pset: p, mnemonic: mnemonic),
    );
  }
  return signed;
}

class LiquidBatchBroadcastResult {
  const LiquidBatchBroadcastResult({
    required this.signedPset,
    required this.success,
    this.txid,
    this.error,
  });

  final String signedPset;
  final bool success;
  final String? txid;
  final String? error;
}

/// Broadcasts each signed PSET in order, continuing past individual failures
/// and reporting every PSET's outcome instead of aborting on the first error.
Future<List<LiquidBatchBroadcastResult>> batchBroadcast({
  required List<String> signedPsets,
  required LiquidNetwork network,
  required String electrumUrl,
}) async {
  final results = <LiquidBatchBroadcastResult>[];
  for (final s in signedPsets) {
    try {
      final txid = await Blockchain.broadcastSignedPset(
        network: network,
        electrumUrl: electrumUrl,
        signedPset: s,
      );
      results.add(
        LiquidBatchBroadcastResult(signedPset: s, success: true, txid: txid),
      );
    } catch (e) {
      final message = e is LwkError ? e.msg : e.toString();
      results.add(
        LiquidBatchBroadcastResult(
          signedPset: s,
          success: false,
          error: message,
        ),
      );
    }
  }
  return results;
}
