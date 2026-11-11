import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bull_sdk/bull_sdk.dart';
import 'package:bull_sdk/lwk.dart' as lwk;
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show ExternalLibrary;
import 'package:flutter_test/flutter_test.dart';

// Explicit opt-in host smoke test: build the aggregate native library, start
// Nigiri's Liquid services, then run `fvm flutter test tool/liquid_regtest_test.dart`.
// Wallet seeds are generated in memory and never written or printed.
void main() {
  test(
    'aggregate SDK receives, signs and broadcasts Liquid regtest',
    () async {
      final http = HttpClient();
      final directory = await Directory.systemTemp.createTemp(
        'bull_lwk_regtest_',
      );
      final random = Random.secure();
      final seed = Uint8List.fromList(
        List.generate(64, (_) => random.nextInt(256)),
      );
      final recipientSeed = Uint8List.fromList(
        List.generate(64, (_) => random.nextInt(256)),
      );
      lwk.Wallet? sender;
      lwk.Wallet? recipient;
      const electrum = 'tcp://127.0.0.1:50001';

      Future<dynamic> post(int port, String path, Object body) async {
        final request = await http.post('127.0.0.1', port, path);
        request.persistentConnection = false;
        request.headers.contentType = ContentType.json;
        if (port == 18884) {
          // Public Nigiri regtest defaults, never a user credential.
          request.headers.set(
            HttpHeaders.authorizationHeader,
            'Basic ${base64Encode(utf8.encode('admin1:123'))}',
          );
        }
        final payload = utf8.encode(jsonEncode(body));
        request.contentLength = payload.length;
        request.add(payload);
        final response = await request.close();
        expect(response.statusCode, 200);
        final text = await utf8.decoder.bind(response).join();
        return jsonDecode(text);
      }

      Future<dynamic> rpc(
        String method, [
        List<Object> params = const [],
      ]) async {
        final response = await post(18884, '/', {
          'jsonrpc': '1.0',
          'id': 1,
          'method': method,
          'params': params,
        });
        expect(response['error'], isNull);
        return response['result'];
      }

      Future<void> syncUntil(lwk.Wallet wallet, BigInt minimum) async {
        final deadline = DateTime.now().add(const Duration(seconds: 90));
        while (DateTime.now().isBefore(deadline)) {
          await wallet.sync_(electrumUrl: electrum, validateDomain: true);
          final balances = await wallet.balances();
          final asset = await wallet.policyAsset();
          final balance = lwk.getBalanceByAssetId(
            balances: balances,
            assetId: asset,
          );
          if (balance >= minimum) return;
          await Future<void>.delayed(const Duration(seconds: 1));
        }
        fail('Liquid wallet did not observe its regtest transfer');
      }

      try {
        expect((await rpc('getblockchaininfo'))['chain'], 'liquidregtest');
        final policyAsset =
            (await rpc('getsidechaininfo'))['pegged_asset'] as String;
        await BullSdk.init(
          externalLibrary: ExternalLibrary.open(
            '../../target/debug/librust_lib_bull_sdk.so',
          ),
        );
        sender = await lwk.Wallet.init(
          network: lwk.LiquidNetwork.regtest,
          dbpath: '${directory.path}/sender',
          policyAsset: policyAsset,
          descriptor: await lwk.Descriptor.newConfidentialFromSeed(
            network: lwk.LiquidNetwork.regtest,
            seed: seed,
          ),
        );
        recipient = await lwk.Wallet.init(
          network: lwk.LiquidNetwork.regtest,
          dbpath: '${directory.path}/recipient',
          policyAsset: policyAsset,
          descriptor: await lwk.Descriptor.newConfidentialFromSeed(
            network: lwk.LiquidNetwork.regtest,
            seed: recipientSeed,
          ),
        );
        final funding = await sender.address(index: 0);
        expect(
          await lwk.Address.validate(addressString: funding.confidential),
          lwk.LiquidNetwork.regtest,
        );
        await post(3001, '/faucet', {
          'address': funding.confidential,
          'amount': 1,
        });
        await syncUntil(sender, BigInt.from(100000000));
        final destination = await recipient.address(index: 0);
        final pset = await sender.buildLbtcTx(
          sats: BigInt.from(10000),
          outAddress: destination.confidential,
          feeRate: 1000,
          drain: false,
        );
        final signed = await sender.signTxWithSeed(
          network: lwk.LiquidNetwork.regtest,
          pset: pset,
          seed: seed,
        );
        final txid = await lwk.Blockchain.broadcastSignedPset(
          network: lwk.LiquidNetwork.regtest,
          electrumUrl: electrum,
          signedPset: signed,
        );
        expect(txid, matches(RegExp(r'^[0-9a-f]{64}$')));
        await rpc('generatetoaddress', [1, destination.standard]);
        await syncUntil(recipient, BigInt.from(10000));
        expect((await recipient.txs()).any((tx) => tx.txid == txid), isTrue);
        final confirmationDeadline = DateTime.now().add(
          const Duration(seconds: 30),
        );
        while (DateTime.now().isBefore(confirmationDeadline) &&
            await lwk.confirmedLbtcUtxoCount(
                  recipient,
                  network: lwk.LiquidNetwork.regtest,
                ) ==
                0) {
          await Future<void>.delayed(const Duration(seconds: 1));
          await recipient.sync_(electrumUrl: electrum, validateDomain: true);
        }
        expect(
          await lwk.confirmedLbtcUtxoCount(
            recipient,
            network: lwk.LiquidNetwork.regtest,
          ),
          greaterThan(0),
        );
        await recipient.sync_(electrumUrl: electrum, validateDomain: true);
        expect(
          await recipient.sync_(electrumUrl: electrum, validateDomain: true),
          isFalse,
        );
      } finally {
        sender?.dispose();
        recipient?.dispose();
        seed.fillRange(0, seed.length, 0);
        recipientSeed.fillRange(0, recipientSeed.length, 0);
        http.close(force: true);
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
