part of pbconv;

//
//  Message composed or parsed from bytes;
//
class EncoderMessage extends Message {
  EncoderMessage(List<Field> fields) : super(fields);

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
