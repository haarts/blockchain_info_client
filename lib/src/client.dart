import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'package:web_socket_channel/io.dart';

class Client {
  Client({String url, String webSocketUrl})
      : url = (url == null) ? Uri.parse(_defaultBlockchainUrl) : Uri.parse(url),
        websocketUrl = (webSocketUrl == null)
            ? Uri.parse(_defaultWebsocketBlockchainUrl)
            : Uri.parse(webSocketUrl);

  /// Used to send an appropriate User-Agent header with the HTTP requests
  static const String _userAgent = 'Blockchain.info - Dart';

  final String _blocksSub = 'blocks_sub';
  final String _unconfirmedSub = 'unconfirmed_sub';
  final String _addressSub = 'addr_sub';

  final String _blockPath = '/rawblock/';
  final String _txPath = '/rawtx/';

  final String _latestBlockPath = '/latestblock';

  static const _headers = {
    HttpHeaders.userAgentHeader: _userAgent,
  };

  static const String _defaultBlockchainUrl = 'https://blockchain.info/';
  static const String _defaultWebsocketBlockchainUrl =
      'wss://ws.blockchain.info/inv';

  /// The URLs of the Blockchain server.
  final Uri websocketUrl;
  final Uri url;

  Future<Map<String, dynamic>> getBlock(String blockHash) async {
    var response = await get(url.replace(path: '$_blockPath$blockHash'));

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getLatestBlock() async {
    var response = await get(url.replace(path: '$_latestBlockPath'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getTransaction(String txHash) async {
    var response = await get(url.replace(path: '$_txPath$txHash'));

    return json.decode(response.body);
  }

  /// Returns a [Stream] of blocks are they get published on the network
  Stream<String> newBlocks() {
    return _streamWith({'op': _blocksSub});
  }

  /// Returns a [Stream] of transactions in the mempool.
  Stream<String> unconfirmedTransactions() {
    return _streamWith({'op': _unconfirmedSub});
  }

  /// Returns a [Stream] of transactions involving [address].
  Stream<String> transactionsForAddress(String address) {
    return _streamWith({'op': _addressSub, 'addr': address});
  }

  Stream<String> _streamWith(Map<String, dynamic> payload) {
    final channel = IOWebSocketChannel.connect(websocketUrl,
        headers: _headers, pingInterval: const Duration(seconds: 10));
    channel.sink.add(json.encode(payload));

    return channel.cast<String>().stream;
  }

  @override
  String toString() => 'Client(url: $websocketUrl)';
}
