part of pbconv;

/** 
 *   Message composed or parsed from bytes; 
*/
class EncoderMessage extends _Message {
  EncoderMessage(List<Field> fields) : super(fields) {}

  Stream<Uint8List> encode(_BytesPager pager) async* {
    assert(review());
    for (_Node node in _nodes.values) {
      yield* node.encode(pager);
    }
  }

  bool review() {
    for (var field in _fields) {
      if (field._label == Label.required && !_nodes.containsKey(field)) {
        return false;
      }
    }
    return true;
  }
} //class end;

class ProtobufEncoder extends Converter<EncoderMessage, Uint8List> {
  ProtobufEncoder() {
  }

  Stream<Uint8List> bind(Stream<_Message> stream) {
    return super.bind(stream);
  }

  Future<List<Uint8List>> _pull(Stream<Uint8List> stream) async {
    List<Uint8List> bytesList = List<Uint8List>();
    await for (var bytes in stream) {
      bytesList.add(bytes);
    }
    return bytesList;
  }

  Stream<Uint8List> _encode(
      _BytesPager pager, EncoderMessage message) async* {
    yield* message.encode(pager);
    yield* pager.commit();
  }

  Uint8List convert(EncoderMessage message) {
    _BytesPager pager = _BytesPager(128);
    Stream<Uint8List> stream = _encode(pager, message);
    var bytesList = waitFor(_pull(stream));
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
    return result;
  }

  ChunkedConversionSink<EncoderMessage> startChunkedConversion(Sink<Uint8List> sink) {
    return null;
  }

  Converter<EncoderMessage, T> fuse<T>(Converter<Uint8List, T> other) {
    return super.fuse<T>(other);
  }
}
