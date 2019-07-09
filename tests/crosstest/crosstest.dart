import 'dart:core';
import "dart:io";
import 'dart:typed_data';

import "package:pbconv/pbconv.dart";

class Coordinate {
  Coordinate(double x, double y) {
    longitude = x;
    latitude = y;
  }
  double longitude;
  double latitude;

  static final List<Field> fields = [
    RequiredField(1, "Longitude", Type.float64),
    RequiredField(2, "Latitude", Type.float64)
    ];

  static EncoderMessage createEncoder(double longitude, double latitude) {
    return CoordinateEncoder(longitude, latitude);
  }
  static DecoderMessage createDecoder() {
    return CoordinateDecoder();
  }
}

class RequiredCoordinate extends Field {
  RequiredCoordinate(int tag, String name)
      : super(tag, name, Label.required, Type.message,
            value: Coordinate.fields,
            createDecoderFunc: Coordinate.createDecoder) {}
}

class OptionalCoordinate extends Field {
  OptionalCoordinate(int tag, String name)
      : super(tag, name, Label.optional, Type.message,
            value: Coordinate.fields,
            createDecoderFunc: Coordinate.createDecoder) {}
}

class CoordinateEncoder extends EncoderMessage {
  CoordinateEncoder(double longitude, latitude) : super(Coordinate.fields) {
    this[Coordinate.fields[0]] = longitude;
    this[Coordinate.fields[1]] = latitude;
  }
}

class CoordinateDecoder extends DecoderMessage {
  CoordinateDecoder():super(Coordinate.fields) {
  }

  void decode(Field parent, Uint8List bytes, int offset, int end) {
    super.decode(parent, bytes, offset, end);
    _coordinate = Coordinate(this[Coordinate.fields[0]], this[Coordinate.fields[1]]);
  }
  Coordinate get realObject => _coordinate;
  Coordinate _coordinate;
}

//Example of message nodes defintion.
final List<Field> __child_fields__ = [
  RepeatedField(1, "Node1", Type.string),
  RequiredField(2, "Node2", Type.sint32),
];

final List<Field> __root_fileds__ = [
  RequiredField(1, "Node1", Type.int32),
  RepeatedField(2, "Node2", Type.string),
  RequiredField(3, "Node3", Type.bytes),
  RequiredMessage(4, "Child", __child_fields__),
  RequiredTimestamp(5, "Timestamp"), 
  RequiredCoordinate(6, "Coordinate")
];


main() {
  var encoding = true;
  if (encoding) {
    ProtobufEncoder encoder = ProtobufEncoder();

    var root = EncoderMessage(__root_fileds__);
  
    root[__root_fileds__[0]] = -2;

    root[__root_fileds__[1]] = ["sfs", '2233'];

    Uint8List data = Uint8List(8);
    data.buffer.asByteData().setFloat64(0, 0.123);
    root[__root_fileds__[2]] = data;

    var child = EncoderMessage(__child_fields__);
    root[__root_fileds__[3]] = child;

    child[__child_fields__[0]] = ["dsfsdfsd"];
    child[__child_fields__[1]] = 23;

    root[__root_fileds__[4]]= Timestamp.createEncoder(DateTime.now()); //set to now
    root[__root_fileds__[5]]= Coordinate.createEncoder(1, 2);

    Uint8List bytes = encoder.convert(root);
    print(bytes.toList());

    File sample = File("tests/crosstest.bin");
    //sample.createSync();
    sample.writeAsBytesSync(bytes);
    print(root.toString());

  } else {
    File sample = File("tests/crosstest.bin");
    var bytes = sample.readAsBytesSync();
    print(bytes);
    ProtobufDecoder decoder = ProtobufDecoder(__root_fileds__);
    DecoderMessage decoderMessage = decoder.convert(bytes);
    print(decoderMessage.toString());
    print(decoderMessage[__root_fileds__[4]].year);
  }
}
