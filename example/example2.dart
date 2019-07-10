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
  print(bytes);
  ProtobufDecoder decoder = ProtobufDecoder(fields);
  DecoderMessage message = decoder.convert(bytes);
  print(message.toString());
}
