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
  File file = File("readme.bin");
  file.writeAsBytesSync(proto.bytes);
}
