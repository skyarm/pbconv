A implement of Dart converter for [Protobuf](https://developers.google.com/protocol-buffers/).

## Introduction

Convert a message object to *proto buffer* binary bytes, Or convert proto buffer binary bytes to a message object.

## Examples
This is the encoder example.
```dart
import "dart:io";
import 'package:pbconv/pbconv.dart';

final List<Field> fields = [
  RequiredField(1, 'ID', Type.uint32),
  RequiredField(2, "Name", Type.string),
  OptionalField(3, "Email", Type.string, 'tom@example.com')
];

main() {
  var message = EncoderMessage(fields);
  message[fields[0]] = 1;
  message[fields[1]] = 'Tom';
  var proto = protobufEncode(message);
  print(proto.bytes);
  File file = File("example.bin");
  file.writeAsBytesSync(proto.bytes);
}
```

This is decoder example.
```dart
import "dart:io";
import 'dart:typed_data';
import 'package:pbconv/pbconv.dart';

final List<Field> fields = [
  RequiredField(1, 'ID', Type.uint32),
  RequiredField(2, "Name", Type.string),
  OptionalField(3, "Email", Type.string, 'tom@example.com')
];

main() {
  File file = File("example.bin");
  var bytes = file.readAsBytesSync();
  print(bytes);
  var message = protobufDecode(ProtoBytes(fields, bytes as Uint8List));
  print(message.toString());
}
```

## Features and bugs
Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/skyarm/pbconv/issues
