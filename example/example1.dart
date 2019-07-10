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
  var bytes = encoder.convert(message);
  print(bytes);
  File file = File("example.bin");
  file.writeAsBytesSync(bytes);
}