# Blockchain.info library

[![pub package](https://img.shields.io/pub/v/blockchain_info.svg)](https://pub.dartlang.org/packages/blockchain_info)

A library for communicating with the [Blockchain.info API](https://www.blockchain.com/api/api_websocket).

## Examples

Listen for all new blocks:

```dart
  var client =
      Client.websocket("wss://ws.blockchain.info/inv");

  Stream<String> blocks = await client.newBlocks();
  await for (String block in blocks) {
    print("new block: $block");
  }
```

## Installing

Add it to your `pubspec.yaml`:

```
dependencies:
  blockchain_info: 0.1.0
```

## Licence overview

All files in this repository fall under the license specified in 
[COPYING](COPYING). The project is licensed as [AGPL with a lesser clause](https://www.gnu.org/licenses/agpl-3.0.en.html). 
It may be used within a proprietary project, but the core library and any 
changes to it must be published online. Source code for this library must 
always remain free for everybody to access.