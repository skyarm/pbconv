part of pbconv;

const ProtobufCodec protobuf = ProtobufCodec();

class ProtoBytes {
  ProtoBytes(List<Field> fields, Uint8List bytes) {
    _fields = fields;
    _bytes = bytes;
  }
  List<Field> get fields => _fields;
  Uint8List get bytes => _bytes;

  List<Field> _fields;
  Uint8List _bytes;
}

class ProtobufCodec extends Codec<Message, ProtoBytes> {
  const ProtobufCodec();

  Message decode(ProtoBytes proto) {
    return ProtobufDecoder().convert(proto);
  }

  @override
  ProtoBytes encode(Message message) {
    return ProtobufEncoder().convert(message as EncoderMessage);
  }

  ProtobufEncoder get encoder {
    return ProtobufEncoder();
  }

  ProtobufDecoder get decoder {
    return ProtobufDecoder();
  }
}

ProtoBytes protobufEncode(Message message) {
  return protobuf.encode(message);
}

Message protobufDecode(ProtoBytes proto) {
  return protobuf.decode(proto);
}

class ProtobufEncoder extends Converter<EncoderMessage, ProtoBytes> {
  const ProtobufEncoder();

  Stream<Uint8List> encode(_BytesPager pager, EncoderMessage message) async* {
    yield* message.encode(pager);
    yield* pager.commit();
  }

  ProtoBytes convert(EncoderMessage message) {
    _BytesPager pager = _BytesPager();
    Stream<Uint8List> stream = encode(pager, message);
    var bytesList = waitFor(stream.toList());
    int count = 0;
    for (var bytes in bytesList) {
      count += bytes.length;
    }
    Uint8List result = Uint8List(count);
    int offset = 0;
    for (var bytes in bytesList) {
      result.setRange(offset, offset + bytes.length, bytes);
      offset += bytes.length;
    }
    return ProtoBytes(message._fields, result);
  }

  ChunkedConversionSink<EncoderMessage> startChunkedConversion(
      Sink<ProtoBytes> sink) {
    return _ProtobufEncoderSink(sink);
  }

  static int encoderPageSize = 128;
}

class _ProtobufEncoderSink extends ChunkedConversionSink<EncoderMessage> {
  final Sink<ProtoBytes> _sink;
  bool _isDone = false;

  _ProtobufEncoderSink(this._sink);

  void add(EncoderMessage m) {
    if (_isDone) {
      throw StateError("Only one call to add allowed");
    }
    var pager = _BytesPager();
    waitFor((_sink as IOSink).addStream(encode(pager, m)));
    _isDone = true;
    _sink.close();
  }

  Stream<Uint8List> encode(_BytesPager pager, EncoderMessage message) async* {
    yield* message.encode(pager);
    yield* pager.commit();
  }

  void close() {/* do nothing */}
}

class ProtobufDecoder extends Converter<ProtoBytes, Message> {
  const ProtobufDecoder();

  DecoderMessage convert(ProtoBytes proto) {
    DecoderMessage message = DecoderMessage(proto._fields);
    message.decode(null, proto._bytes, 0, proto._bytes.length);
    return message;
  }

  Message decode(Stream<ProtoBytes> stream) {
    var bytesList = waitFor(stream.toList());
     int count = 0; 
    List<Field> fields;
    for (var proto in bytesList) {
      if (fields == null) {
        fields = proto.fields;
      } else {
        if (proto.fields != fields) {
          throw StateError("Field list value is changed.");
        }
      }
      count += proto.bytes.length;
    }
    Uint8List result = Uint8List(count);
    int offset = 0;
    for (var proto in bytesList) {
      result.setRange(offset, offset + proto.bytes.length, proto.bytes);
      offset += proto.bytes.length;
    }
    return protobufDecode(ProtoBytes(fields, result));
  }

  ChunkedConversionSink<ProtoBytes> startChunkedConversion(Sink<Message> sink) {
    return _ProtobufDecoderSink(sink);
  }
}

class _ProtobufDecoderSink extends ChunkedConversionSink<ProtoBytes> {
  final Sink<Message> _sink;

  _ProtobufDecoderSink(this._sink);

  void add(ProtoBytes proto) {
    if (_fields == null) {
      _fields = proto.fields;
    } else {
      if (proto.fields != _fields) {
        throw StateError("Field list value is changed.");
      }
    }
    _bytesList.add(proto.bytes);
  }

  void close() {
    decode();
    _sink.close();
  }

  void decode() {
    int count = 0;
    for (var bytes in _bytesList) {
      count += bytes.length;
    }
    Uint8List result = Uint8List(count);
    int offset = 0;
    for (var bytes in _bytesList) {
      result.setRange(offset, offset + bytes.length, bytes);
      offset += bytes.length;
    }
    Message message = protobufDecode(ProtoBytes(_fields, result));
    _sink.add(message);
  }

  List<Field> _fields;
  List<Uint8List> _bytesList;
}
