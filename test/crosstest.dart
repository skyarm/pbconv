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

  static EncoderMessage createEncoder(Coordinate coord) {
    return CoordinateEncoder(coord);
  }

  static DecoderMessage createDecoder(dynamic value) {
    return CoordinateDecoder();
  }
}

class RequiredCoordinate extends Field {
  RequiredCoordinate(int tag, String name)
      : super(tag, name, Label.required, Type.message,
            value: Coordinate.fields,
            attrs: Coordinate.createDecoder);
}

class OptionalCoordinate extends Field {
  OptionalCoordinate(int tag, String name)
      : super(tag, name, Label.optional, Type.message,
            value: Coordinate.fields,
            attrs: Coordinate.createDecoder);
}

class CoordinateEncoder extends EncoderMessage {
  CoordinateEncoder(Coordinate coord) : super(Coordinate.fields) {
    assert(coord != null);
    this[Coordinate.fields[0]] = coord.longitude;
    this[Coordinate.fields[1]] = coord.latitude;
  }
}

class CoordinateDecoder extends DecoderMessage {
  CoordinateDecoder() : super(Coordinate.fields);

  void decode(Field parent, Uint8List bytes, int offset, int end) {
    super.decode(parent, bytes, offset, end);
    _coordinate = Coordinate(this[Coordinate.fields[0]] as double,
        this[Coordinate.fields[1]] as double);
  }

  Coordinate get realObject => _coordinate;
  Coordinate _coordinate;
}

final List<Field> childFields = [
  RepeatedField(1, "Node1", Type.string),
  RequiredField(2, "Node2", Type.sint32),
];

final List<Field> rootFileds = [
  RequiredField(1, "Node1", Type.int32),
  RepeatedField(2, "Node2", Type.string),
  RequiredField(3, "Node3", Type.bytes),
  RequiredMessage(4, "Child", childFields),
  RequiredTimestamp(5, "Timestamp"),
  RequiredCoordinate(6, "Coordinate")
];

main() {
  var encoding = false;
  if (encoding) {
    ProtobufEncoder encoder = ProtobufEncoder();

    var root = EncoderMessage(rootFileds);

    root[rootFileds[0]] = -2;

    root[rootFileds[1]] = ["sfs", '2233'];

    Uint8List data = Uint8List(8);
    data.buffer.asByteData().setFloat64(0, 0.123);
    root[rootFileds[2]] = data;

    var child = EncoderMessage(childFields);
    root[rootFileds[3]] = child;

    child[childFields[0]] = ["dsfsdfsd"];
    child[childFields[1]] = 23;

    root[rootFileds[4]] = Timestamp.createEncoder(DateTime.now()); //set to now
    root[rootFileds[5]] = Coordinate.createEncoder(Coordinate(12.11, 34.23));

    Uint8List bytes = encoder.convert(root);
    print(bytes.toList());

    File sample = File("tests/crosstest/crosstest.bin");
    //sample.createSync();
    sample.writeAsBytesSync(bytes);
    print(root.toString());
  } else {
    File sample = File("tests/crosstest/crosstest.bin");
    var bytes = sample.readAsBytesSync();
    print(bytes);
    ProtobufDecoder decoder = ProtobufDecoder(rootFileds);
    DecoderMessage decoderMessage = decoder.convert(bytes as Uint8List);
    print(decoderMessage.toString());

    print(
        "TimerStamp: ${decoderMessage[rootFileds[4]].year}, ${decoderMessage[rootFileds[4]].month}");

    print(
        "Coord: ${decoderMessage[rootFileds[5]].longitude}, ${decoderMessage[rootFileds[5]].latitude}");
  }
}
