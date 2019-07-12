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
  if (file.existsSync()) {
    var bytes = file.readAsBytesSync();
    print(bytes);
    ProtobufDecoder decoder = ProtobufDecoder();
    DecoderMessage message = decoder.convert(ProtoBytes(fields, bytes as Uint8List));
    print(message.toString());
  } else {
    var message = EncoderMessage(fields);
    message[fields[0]] = 1;
    message[fields[1]] = 'Tom';
    ProtobufEncoder encoder = ProtobufEncoder();
    var proto = encoder.convert(message);
    print(proto.bytes);
    file.writeAsBytesSync(proto.bytes);
  }
}
