import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:mock_web_server/mock_web_server.dart';

import 'package:blockchain_info/blockchain_info.dart';

MockWebServer server;
Client client;

void main() {
  setUp(() async {
    server = MockWebServer();
    await server.start();
    client = Client(webSocketUrl: "ws://${server.host}:${server.port}/ws");
  });

  tearDown(() async {
    server.shutdown();
  });

  test("initialize", () {
    expect(client, isNotNull);
    expect(client.websocketUrl.host, "127.0.0.1");
  });

  test("transactionConfirmation()", () async {
    var cannedResponse = await File('files/transaction.json').readAsString();
    server.enqueue(body: cannedResponse);
    Stream<String> transactions =
        client.transactionsForAddress("17XsaAEW8Rm73bRxhrw8REyEZ4Kg8XCRXr");
    transactions.listen(expectAsync1((message) {}, count: 1));
  });

  test("newBlocks()", () async {
    var cannedResponse = await File('files/block.json').readAsString();
    server.enqueue(body: cannedResponse);
    Stream<String> blocks = await client.newBlocks();
    blocks.listen(expectAsync1((message) {}, count: 1));
  });

  test("unconfirmedTransactions()", () async {
    var tx1 = await File('files/unconfirmed_1.json').readAsString();
    var tx2 = await File('files/unconfirmed_2.json').readAsString();
    server.messageGenerator = (StreamSink sink) async {
      sink.add(tx1);
      sink.add(tx2);
    };

    Stream<String> blocks = await client.unconfirmedTransactions();
    blocks.listen(expectAsync1((message) {}, count: 2));
  });
}
