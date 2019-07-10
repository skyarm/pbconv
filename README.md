A implement of Dart converter for [Protobuf](https://developers.google.com/protocol-buffers/).

## Introduce
Convert a message object to proto buffer binary bytes, Or convert proto buffer binary bytes to a message object.

## Using

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
  ProtobufEncoder encoder = ProtobufEncoder();
  print(encoder.convert(message));
  File file = File("example.bin");
  file.writeAsBytesSync(bytes);
}
```

This is decoder example.
```dart
import "dart:io";
import 'package:pbconv/pbconv.dart';

final List<Field> fields = [
  RequiredField(1, 'ID', Type.uint32),
  RequiredField(2, "Name", Type.string),
  OptionalField(3, "Email", Type.string, 'tom@example.com')
];

main() {
  File file = File("example.bin");
  var bytes = file.readAsBytesSync();
  ProtobufDecoder decoder = ProtobufDecoder(fields);
  DecoderMessage message = decoder.convert(bytes);
  print(message.toString());
}
```

## Features and bugs
Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/skyarm/pbconv/issues
