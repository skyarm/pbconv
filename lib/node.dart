part of pbconv;
//
//
//

enum _Wire {
  varint, //variable length integer, etc uint32, sint32 uint64 sint64.
  num64, //fixed 64bit number, etc double, fixed64, sfixed64.
  length,
  start_group,
  end_group,
  num32
}

class _BytesPager {
  _BytesPager(int size) {
    _offset = 0;
    _size = size;
    _bytes = new Uint8List(_size);
  }

  Stream<Uint8List> commit() async* {
    if (_offset > 0) {
      Uint8List byteList = Uint8List(_offset);
      for (int index = 0; index < _offset; index++) {
        byteList[index] = _bytes[index];
      }
      yield byteList;
    }
  }

  Stream<Uint8List> add(int v) async* {
    _bytes[_offset] = v;
    yield* _ifNextPage();
  }

  Stream<Uint8List> addBytes(Uint8List bytes, [int length = -1]) async* {
    int count = length == -1 ? bytes.length : length;
    for (int index = 0; index < count; index++) {
      yield* add(bytes[index]);
    }
  }

  Stream<Uint8List> addBytesList(List<Uint8List> bytesList) async* {
    for (var bs in bytesList) {
      yield* addBytes(bs);
    }
  }

  Uint8List _newBytes(int size) {
    return Uint8List(size);
  }

  Stream<Uint8List> _ifNextPage() async* {
    if (_offset >= _bytes.length) {
      var bl = _bytes;
      _bytes = _newBytes(_size);
      _offset = 0;
      yield bl;
    } else {
      _offset++;
    }
  }

  int get size => _size;
  int get offset => _offset;
  get bytes => _bytes;

  Uint8List _bytes;
  int _offset;
  int _size;
}

abstract class _Node {
  _Node(Field field) {
    _field = field;
  }

  Stream<Uint8List> encode(_BytesPager bytesPager) async* {}

  int zigzag32(int v) {
    if (v < 0) {
      return -v * 2 - 1;
    } else {
      return v * 2;
    }
  }

  int zigzag64(int v) {
    if (v < 0) {
      return -v * 2 - 1;
    } else {
      return v * 2;
    }
  }

  Stream<Uint8List> encodeUint32(_BytesPager bytesPager, int value) async* {
    value &= 0xffffffff;
    if (value >= 0x80) {
      yield* bytesPager.add(value | 0x80);
      value >>= 7;
      if (value >= 0x80) {
        yield* bytesPager.add(value | 0x80);
        value >>= 7;
        if (value >= 0x80) {
          yield* bytesPager.add(value | 0x80);
          value >>= 7;
          if (value >= 0x80) {
            yield* bytesPager.add(value | 0x80);
            value >>= 7;
          }
        }
      }
    }
    assert(value < 128);
    yield* bytesPager.add(value);
  }

  Stream<Uint8List> encodeUint64(_BytesPager pager, int value) async* {
    int hign = (value >> 32) & 0xffffffff;
    int low = value & 0xffffffff;
    if (hign == 0) {
      yield* encodeUint32(pager, low);
      return;
    }
    yield* pager.add(low | 0x80);
    yield* pager.add((low >> 7) | 0x80);
    yield* pager.add((low >> 14) | 0x80);
    yield* pager.add((low >> 21) | 0x80);
    if (hign < 8) {
      yield* pager.add((hign << 4) | (low >> 28));
      return;
    } else {
      yield* pager.add(((hign & 7) << 4) | (low >> 28) | 0x80);
      hign >>= 3;
    }

    while (hign >= 128) {
      yield* pager.add(hign | 0x80);
      hign >>= 7;
    }
    yield* pager.add(hign);
  }

  Stream<Uint8List> encodeInt32(_BytesPager bytesPager, int value) async* {
    if (value < 0) {
      yield* bytesPager.add(value | 0x80);
      yield* bytesPager.add((value >> 7) | 0x80);
      yield* bytesPager.add((value >> 14) | 0x80);
      yield* bytesPager.add((value >> 21) | 0x80);
      yield* bytesPager.add((value >> 28) | 0x80);
      yield* bytesPager.add(0xff);
      yield* bytesPager.add(0xff);
      yield* bytesPager.add(0xff);
      yield* bytesPager.add(0xff);
      yield* bytesPager.add(0x01);
    } else {
      yield* encodeUint32(bytesPager, value);
    }
  }

  Stream<Uint8List> encodeSint32(_BytesPager bytesPager, int value) async* {
    yield* encodeUint32(bytesPager, zigzag32(value));
  }

  Stream<Uint8List> encodeSint64(_BytesPager bytesPager, int value) async* {
    yield* encodeUint64(bytesPager, zigzag64(value));
  }

  Stream<Uint8List> encodeFixedU32(_BytesPager pager, int value) async* {
    var bytes = Uint8List(4);
    var byteData = bytes.buffer.asByteData();
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    byteData.setUint32(0, value, Endian.little);
    yield* pager.addBytes(bytes);
  }

  Stream<Uint8List> encodeFixedS32(_BytesPager pager, int value) async* {
    var bytes = Uint8List(4);
    var byteData = bytes.buffer.asByteData();
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    byteData.setInt32(0, value, Endian.little);
    yield* pager.addBytes(bytes);
  }

  Stream<Uint8List> encodeFixedU64(_BytesPager pager, int value) async* {
    var bytes = Uint8List(8);
    var byteData = bytes.buffer.asByteData();
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    byteData.setUint64(0, value, Endian.little);
    yield* pager.addBytes(bytes);
  }

  Stream<Uint8List> encodeFixedS64(_BytesPager pager, int value) async* {
    var bytes = Uint8List(8);
    var byteData = bytes.buffer.asByteData();
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    byteData.setInt64(0, value, Endian.little);
    yield* pager.addBytes(bytes);
  }

  Stream<Uint8List> encodeFloat32(_BytesPager pager, double value) async* {
    var bytes = Uint8List(4);
    var byteData = bytes.buffer.asByteData();
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    byteData.setFloat32(0, value, Endian.little);
    yield* pager.addBytes(bytes);
  }

  Stream<Uint8List> encodeFloat64(_BytesPager pager, double value) async* {
    var bytes = Uint8List(8);
    var byteData = bytes.buffer.asByteData();
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    byteData.setFloat64(0, value, Endian.little);
    yield* pager.addBytes(bytes);
  }

  Stream<Uint8List> encodeBoolean(_BytesPager pager, bool value) async* {
    yield* pager.add(value ? 1 : 0);
  }

  Stream<Uint8List> encodeString(_BytesPager pager, String value) async* {
    Uint8List bytes = utf8.encode(value);
    yield* encodeUint32(pager, bytes.length);
    yield* pager.addBytes(bytes);
  }

  Stream<Uint8List> encodeBytes(_BytesPager pager, Uint8List value) async* {
    yield* encodeUint32(pager, value.length);
    yield* pager.addBytes(value);
  }

  Stream<Uint8List> encodeTag(_BytesPager pager, _Wire value) async* {
    int start = pager.offset;
    if (_field._tag < (1 << (32 - 3))) {
      yield* encodeUint32(pager, _field._tag << 3);
    } else {
      yield* encodeUint64(pager, _field._tag << 3);
    }
    pager.bytes[start] |= value.index;
  }

  static Future<List<Uint8List>> pullBytes(Stream<Uint8List> stream) async {
    var bytesList = List<Uint8List>();
    await for (var bl in stream) {
      bytesList.add(bl);
    }
    return bytesList;
  }

  String toString() {
    return null;
  }

  Field _field;
}

class _BooleanNode extends _Node {
  _BooleanNode(Field field, bool value) : super(field) {
    _value = value;
  }

  Stream<Uint8List> encode(_BytesPager pager) async* {
    yield* encodeTag(pager, _Wire.varint);
    yield* encodeBoolean(pager, _value);
  }

  String toString() {
    String xml = "<" + _field._name + ">";
    xml += _value.toString();
    xml += "</" + _field._name + ">";
    return xml;
  }

  bool _value;
}

class _RepeatedBooleanNode extends _Node {
  _RepeatedBooleanNode(Field node, List<bool> values) : super(node) {
    _values = values;
  }

  Stream<Uint8List> encode(_BytesPager pager) async* {
    if (_field._packed) {
      yield* encodeTag(pager, _Wire.length);
      yield* encodeUint32(pager, _values.length);
      for (var v in _values) {
        yield* encodeBoolean(pager, v);
      }
    } else {
      for (var v in _values) {
        yield* encodeTag(pager, _Wire.varint);
        yield* encodeBoolean(pager, v);
      }
    }
  }

  String toString() {
    String xml = "<" + _field._name + ">";
    xml += _values.toString();
    xml += "</" + _field._name + ">";
    return xml;
  }

  List<bool> _values;
}

class _NumberNode extends _Node {
  _NumberNode(Field field, num value) : super(field) {
    _value = value;
  }

  Stream<Uint8List> encode(_BytesPager pager) async* {
    switch (_field._type) {
      case Type.enumerated:
      case Type.uint32:
        yield* encodeTag(pager, _Wire.varint);
        yield* encodeUint32(pager, _value.toInt());
        break;
      case Type.sint32:
        yield* encodeTag(pager, _Wire.varint);
        yield* encodeSint32(pager, _value.toInt());
        break;
      case Type.fixed32:
        yield* encodeTag(pager, _Wire.num32);
        yield* encodeFixedU32(pager, _value.toInt());
        break;
      case Type.sfixed32:
        yield* encodeTag(pager, _Wire.num32);
        yield* encodeFixedS32(pager, _value.toInt());
        break;
      case Type.float32:
        yield* encodeTag(pager, _Wire.num32);
        yield* encodeFloat32(pager, _value.toDouble());
        break;
      case Type.int32:
        yield* encodeTag(pager, _Wire.varint);
        yield* encodeInt32(pager, _value.toInt());
        break;
      case Type.uint64:
      case Type.int64:
        yield* encodeTag(pager, _Wire.varint);
        yield* encodeUint64(pager, _value.toInt());
        break;
      case Type.sint64:
        yield* encodeTag(pager, _Wire.varint);
        yield* encodeSint64(pager, _value.toInt());
        break;
      case Type.fixed64:
        yield* encodeTag(pager, _Wire.num64);
        yield* encodeFixedU64(pager, _value.toInt());
        break;
      case Type.sfixed64:
        yield* encodeTag(pager, _Wire.num64);
        yield* encodeFixedS64(pager, _value.toInt());
        break;
      case Type.float64:
        yield* encodeTag(pager, _Wire.num64);
        yield* encodeFloat64(pager, _value.toDouble());
        break;
      default:
        assert(false);
        break;
    }
  }
  //Get a XML string, for debug.
  String toString() {
    String xml = "<" + _field._name + ">";
    xml += _value.toString();
    xml += "</" + _field._name + ">";
    return xml;
  }

  num _value;
}

class _TempNumbersNode extends _Node {
  _TempNumbersNode(Field node, List<num> values) : super(node) {
    _values = values;
  }
  Stream<Uint8List> encode(_BytesPager pager) async* {
    for (var value in _values) {
      switch (_field._type) {
        case Type.enumerated:
        case Type.uint32:
          yield* encodeUint32(pager, value.toInt());
          break;
        case Type.sint32:
          yield* encodeSint32(pager, value.toInt());
          break;
        case Type.fixed32:
          yield* encodeFixedU32(pager, value.toInt());
          break;
        case Type.sfixed32:
          yield* encodeFixedS32(pager, value.toInt());
          break;
        case Type.float32:
          yield* encodeFloat32(pager, value.toDouble());
          break;
        case Type.int32:
          yield* encodeInt32(pager, value.toInt());
          break;
        case Type.uint64:
        case Type.int64:
          yield* encodeUint64(pager, value.toInt());
          break;
        case Type.sint64:
          yield* encodeSint64(pager, value.toInt());
          break;
        case Type.fixed64:
          yield* encodeFixedU64(pager, value.toInt());
          break;
        case Type.sfixed64:
          yield* encodeFixedS64(pager, value.toInt());
          break;
        case Type.float64:
          yield* encodeFloat64(pager, value.toDouble());
          break;
        default:
          assert(false);
          break;
      }
    }
  }

  List<num> _values;
}

class _RepeatedNumberNode extends _Node {
  _RepeatedNumberNode(Field field, List<num> values) : super(field) {
    _values = values;
  }

  Stream<Uint8List> encode(_BytesPager pager) async* {
    if (_field._packed) {
      yield* encodeTag(pager, _Wire.length);
      //calc the length of packed nodes
      var numbersNode = _TempNumbersNode(_field, _values);
      var numbersPager = _BytesPager(pager.size);
      Stream<Uint8List> stream = numbersNode.encode(numbersPager);
      List<Uint8List> bytesList = await _Node.pullBytes(stream);

      //Write message length to the pager;
      int total = bytesList.length * numbersPager.size;
      total += numbersPager.offset;
      yield* encodeUint32(pager, total);

      //Copy the temp bytes to the pager;
      yield* pager.addBytesList(bytesList);
      yield* pager.addBytes(numbersPager.bytes, numbersPager.offset);
      //now all the bytes are copied from stream to this stream;
    } else {
      for (var value in _values) {
        switch (_field._type) {
          case Type.enumerated:
          case Type.uint32:
            yield* encodeTag(pager, _Wire.varint);
            yield* encodeUint32(pager, value.toInt());
            break;
          case Type.sint32:
            yield* encodeTag(pager, _Wire.varint);
            yield* encodeSint32(pager, value.toInt());
            break;
          case Type.fixed32:
            yield* encodeTag(pager, _Wire.num32);
            yield* encodeFixedU32(pager, value.toInt());
            break;
          case Type.sfixed32:
            yield* encodeTag(pager, _Wire.num32);
            yield* encodeFixedS32(pager, value.toInt());
            break;
          case Type.float32:
            yield* encodeTag(pager, _Wire.num32);
            yield* encodeFloat32(pager, value.toDouble());
            break;
          case Type.int32:
            yield* encodeTag(pager, _Wire.varint);
            yield* encodeInt32(pager, value.toInt());
            break;
          case Type.uint64:
          case Type.int64:
            yield* encodeTag(pager, _Wire.varint);
            yield* encodeUint64(pager, value.toInt());
            break;
          case Type.sint64:
            yield* encodeTag(pager, _Wire.varint);
            yield* encodeSint64(pager, value.toInt());
            break;
          case Type.fixed64:
            yield* encodeTag(pager, _Wire.num64);
            yield* encodeFixedU64(pager, value.toInt());
            break;
          case Type.sfixed64:
            yield* encodeTag(pager, _Wire.num64);
            yield* encodeFixedS64(pager, value.toInt());
            break;
          case Type.float64:
            yield* encodeTag(pager, _Wire.num64);
            yield* encodeFloat64(pager, value.toDouble());
            break;
          default:
            assert(false);
            break;
        }
      }
    }
  }

  String toString() {
    String xml = "<" + _field._name + ">";
    xml += _values.toString();
    xml += "</" + _field._name + ">";
    return xml;
  }

  List<num> _values;
}

class _StringNode extends _Node {
  _StringNode(Field field, String value) : super(field) {
    _value = value;
  }

  Stream<Uint8List> encode(_BytesPager pager) async* {
    yield* encodeTag(pager, _Wire.length);
    yield* encodeString(pager, _value);
  }

  String toString() {
    String xml = "<" + _field._name + ">";
    xml += _value;
    xml += "</" + _field._name + ">";
    return xml;
  }

  String _value;
}

class _RepeatedStringNode extends _Node {
  _RepeatedStringNode(Field field, List<String> values) : super(field) {
    _values = values;
  }

  Stream<Uint8List> encode(_BytesPager pager) async* {
    for (var value in _values) {
      yield* encodeTag(pager, _Wire.length);
      yield* encodeString(pager, value);
    }
  }

  String toString() {
    String xml = "<" + _field._name + ">";
    xml += _values.toString();
    xml += "</" + _field._name + ">";
    return xml;
  }

  List<String> _values;
}

class _BytesNode extends _Node {
  _BytesNode(Field field, Uint8List value) : super(field) {
    _value = value;
  }

  Stream<Uint8List> encode(_BytesPager pager) async* {
    yield* encodeTag(pager, _Wire.length);
    yield* encodeBytes(pager, _value);
  }

  String toString() {
    String xml = "<" + _field._name + ">";
    xml += _value.toString();
    xml += "</" + _field._name + ">";
    return xml;
  }

  Uint8List _value;
}

class _RepeatedBytesNode extends _Node {
  _RepeatedBytesNode(Field field, List<Uint8List> values) : super(field) {
    _values = values;
  }

  Stream<Uint8List> encode(_BytesPager pager) async* {
    for (var v in _values) {
      yield* encodeTag(pager, _Wire.length);
      yield* encodeBytes(pager, v);
    }
  }

  String toString() {
    String xml = "<" + _field._name + ">";
    xml += _values.toString();
    xml += "</" + _field._name + ">";
    return xml;
  }

  List<Uint8List> _values;
}

class _TempMessageNode extends _Node {
  _TempMessageNode(Field field, _Message value) : super(field) {
    _value = value;
  }

  Stream<Uint8List> encode(_BytesPager pager) async* {
    yield* _value.encode(pager);
  }

  EncoderMessage _value;
}

class _MessageNode extends _Node {
  _MessageNode(Field field, _Message value) : super(field) {
    _value = value;
  }

  Stream<Uint8List> encode(_BytesPager pager) async* {
    yield* encodeTag(pager, _Wire.length);

    //calc the length of message
    var messageNode = _TempMessageNode(_field, _value);
    var messgePager = _BytesPager(pager.size);
    List<Uint8List> bytesList =
        await _Node.pullBytes(messageNode.encode(messgePager));

    yield* encodeUint32(
        pager, bytesList.length * messgePager.size + messgePager.offset);

    yield* pager.addBytesList(bytesList);
    yield* pager.addBytes(messgePager.bytes, messgePager.offset);
  }

  String toString() {
    String xml = "<" + _field._name + ">";
    xml += _value.toString();
    xml += "</" + _field._name + ">";
    return xml;
  }

  _Message _value;
}

class _RepeatedMessageNode extends _Node {
  _RepeatedMessageNode(Field field, List<_Message> values) : super(field) {
    _values = values;
  }

  Stream<Uint8List> encode(_BytesPager pager) async* {
    for (var v in _values) {
      yield* v.encode(pager);
    }
  }

  String toString() {
    String xml = "<" + _field._name + ">";
    for (var message in _values) {
      xml += message.toString();
    }
    xml += "</" + _field._name + ">";
    return xml;
  }

  List<EncoderMessage> _values;
}
