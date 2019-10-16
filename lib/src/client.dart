import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/io.dart';

class Client {
  /// Used to send an appropriate User-Agent header with the HTTP requests
  static const String _userAgent = 'Blockchain.info - Dart';

  final String _blocksSub = "blocks_sub";
  final String _unconfirmedSub = "unconfirmed_sub";
  final String _addressSub = "addr_sub";

  static const _headers = {
    HttpHeaders.userAgentHeader: _userAgent,
  };

  static final String _defaultBlockchainUrl = "wss://ws.blockchain.info/inv";

  /// The URL of the Blockchain server.
  final Uri websocketUrl;

  Client.websocket([String url])
      : websocketUrl =
            (url == null) ? Uri.parse(_defaultBlockchainUrl) : Uri.parse(url);

  /// Returns a [Stream] of blocks are they get published on the network
  Stream<String> newBlocks() {
    return _streamWith({"op": _blocksSub});
  }

  /// Returns a [Stream] of transactions in the mempool.
  Stream<String> unconfirmedTransactions() {
    return _streamWith({"op": _unconfirmedSub});
  }

  /// Returns a [Stream] of transactions involving [address].
  Stream<String> transactionsForAddress(String address) {
    return _streamWith({"op": _addressSub, "addr": address});
  }

  Stream<String> _streamWith(Map<String, dynamic> payload) {
    final channel = IOWebSocketChannel.connect(websocketUrl,
        headers: _headers, pingInterval: const Duration(seconds: 10));
    channel.sink.add(json.encode(payload));

    return channel.cast<String>().stream;
  }

  @override
  String toString() => "Client(url: $websocketUrl)";
}
