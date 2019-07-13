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

  static EncoderMessage createEncoderMessage(Coordinate coord) {
    return CoordinateEncoder(coord);
  }

  static DecoderMessage createDecoderMessage(dynamic value) {
    return CoordinateDecoder();
  }
}

class RequiredCoordinate extends Field {
  RequiredCoordinate(int tag, String name)
      : super(tag, name, Label.required, Type.message,
            value: Coordinate.fields, attrs: Coordinate.createDecoderMessage);
}

class OptionalCoordinate extends Field {
  OptionalCoordinate(int tag, String name)
      : super(tag, name, Label.optional, Type.message,
            value: Coordinate.fields, attrs: Coordinate.createDecoderMessage);
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

final List<Field> rootFields = [
  RequiredField(1, "Node1", Type.int32),
  RepeatedField(2, "Node2", Type.string),
  RequiredField(3, "Node3", Type.bytes),
  RequiredMessage(4, "Child", childFields),
  RequiredTimestamp(5, "Timestamp"),
  RequiredCoordinate(6, "Coordinate"),
  RequiredTimespan(7, "Duration")
];

main() {
  File file = File("crosstest.bin");
  if (!file.existsSync()) {
    ProtobufEncoder encoder = ProtobufEncoder();

    var root = EncoderMessage(rootFields);

    root[rootFields[0]] = -2;

    root[rootFields[1]] = ["string1", 'string2'];

    root[rootFields[2]] = Uint8List.fromList([12, 3, 4, 5]);

    var child = EncoderMessage(childFields);
    root[rootFields[3]] = child;

    child[childFields[0]] = ["This is a string value."];
    child[childFields[1]] = 23;

    root[rootFields[4]] =
        Timestamp.createEncoderMessage(DateTime.now()); //set to now
    root[rootFields[5]] =
        Coordinate.createEncoderMessage(Coordinate(12.11, 34.23));
    root[rootFields[6]] = Timespan.createEncoderMessage(
        Duration(days: 1, hours: 3, minutes: 23, seconds: 12));

    var proto = encoder.convert(root);
    print(proto.bytes);

    //sample.createSync();
    file.writeAsBytesSync(proto.bytes);
    print(root.toString());
  } else {
    var bytes = file.readAsBytesSync();
    print(bytes);
    ProtobufDecoder decoder = ProtobufDecoder();
    DecoderMessage decoderMessage =
        decoder.convert(ProtoBytes(rootFields, bytes as Uint8List));
    print(decoderMessage.toString());

    print(
        "TimerStamp: ${decoderMessage[rootFields[4]].year}, ${decoderMessage[rootFields[4]].month}");

    print(
        "Coord: ${decoderMessage[rootFields[5]].longitude}, ${decoderMessage[rootFields[5]].latitude}");
  }
}
