//
//
//
//
part of pbconv;

class Fragment {
  Fragment(int tag, int wire, Uint8List bytes) {
    _tag = tag;
    _wire = wire;
    _bytes = bytes;
  }

  get tag => _tag;
  get wire => _wire;
  get bytes => _bytes;

  int _tag;
  int _wire;
  Uint8List _bytes;
}

//
//   Message composed or parsed from bytes;
//
class DecoderMessage extends Message {
  DecoderMessage(List<Field> fields) : super(fields);

  void decode(Field parent, Uint8List bytes, int offset, int end) {
    while (offset < end) {
      int tag, wire;
      int result = _decodeTag(bytes, offset, end - offset);
      if (result == -1) {
        throw FormatException("Failed to decode tag", "", offset);
      }
      tag = result & 0xffffffff;
      wire = (result >> 32) & 0x7;
      offset += (result >> 35);
      if (offset >= end) {
        throw FormatException("Failed to decode tag, bad length", "", offset);
      }

      int length = 0;
      if (wire == _Wire.num32.index) {
        length = 4;
      } else if (wire == _Wire.num64.index) {
        length = 8;
      } else if (wire == _Wire.varint.index) {
        length = _varintLength(bytes, offset, end - offset, 10);
        if (length == -1) {
          throw FormatException(
              "Failed to decode number, bad length", "", offset);
        }
      } else if (wire == _Wire.length.index) {
        result = _decodeLength(bytes, offset, end - offset);
        if (result == -1) {
          throw FormatException("Failed to decode length", "", offset);
        }
        length = result & 0xffffffff;
        offset += result >> 32; //Skip the length varint
      } else {
        throw FormatException("Invalid wire", "", offset);
      }
      //the length is the length of required or optional node,
      //or the count of repeated nodes.
      //if it's count of repeated node, check the region in decodeRepeatedNode method.
      if (offset + length > end) {
        throw FormatException(
            "Failed to decode length, length is too large", "", offset);
      }

      Field field = _lookupField(tag);
      if (field != null) {
        switch (field._label) {
          case Label.required:
          case Label.optional:
            _decodeNode(
                bytes, offset, offset + length, field, wire, length, parent);
            break;
          case Label.repeated:
            _decodeRepeatedNode(
                bytes, offset, offset + length, field, wire, length, parent);
            break;
          default:
            assert(false);
        }
      } else {
        var frag = Fragment(
            tag, wire, bytes.getRange(offset, offset + length) as Uint8List);
        _fragments.add(frag);
      }
      offset += length;
    }
    review();
  }

  void _decodeNode(Uint8List bytes, int offset, int end, Field field, int wire,
      int length, Field parent) {
    switch (field._type) {
      case Type.boolean:
        if (wire != _Wire.varint.index) {
          throw FormatException(
              "Failed to decode boolean, Bad wire", field._name, field._tag);
        }
        _setBool(field, _decodeBoolean(bytes, offset, length));
        break;
      case Type.enumerated:
      case Type.uint32:
        if (wire != _Wire.varint.index) {
          throw FormatException("Failed to decode varint32 number, Bad wire",
              field._name, field._tag);
        }
        _setNumber(field, _decodeUint32(bytes, offset, length));
        break;
      case Type.int32:
        if (wire != _Wire.varint.index) {
          throw FormatException("Failed to decode varint32 number, Bad wire",
              field._name, field._tag);
        }
        //FIMEME: only as Uint64 can get right value.
         _setNumber(field, _decodeUint64(bytes, offset, length));
        break;
      case Type.sint32:
        if (wire != _Wire.varint.index) {
          throw FormatException("Failed to decode varint32 number, Bad wire",
              field._name, field._tag);
        }
        _setNumber(field, _unzigzag32(_decodeUint32(bytes, offset, length)));
        break;
      case Type.fixed32:
        if (wire != _Wire.num32.index) {
          throw FormatException("Failed to decode fixed32 number, Bad wire",
              field._name, field._tag);
        }
        _setNumber(field, _decodeFixed32(bytes, offset, length));
        break;
      case Type.sfixed32:
        if (wire != _Wire.num32.index) {
          throw FormatException("Failed to decode sfixed32 number, Bad wire",
              field._name, field._tag);
        }
        _setNumber(field, _decodeSfixed32(bytes, offset, length));
        break;
      case Type.float32:
        if (wire != _Wire.num32.index) {
          throw FormatException("Failed to decode float32 number, Bad wire",
              field._name, field._tag);
        }
        _setNumber(field, _decodeFloat32(bytes, offset, length));
        break;
      case Type.int64:
      case Type.uint64:
        if (wire != _Wire.varint.index) {
          throw FormatException("Failed to decode varint64 number, Bad wire",
              field._name, field._tag);
        }
        _setNumber(field, _decodeUint64(bytes, offset, length));
        break;
      case Type.sint64:
        if (wire != _Wire.varint.index) {
          throw FormatException("Failed to decode varint64 number, Bad wire",
              field._name, field._tag);
        }
        _setNumber(field, _unzigzag64(_decodeUint64(bytes, offset, length)));
        break;
      case Type.fixed64:
        if (wire != _Wire.num64.index) {
          throw FormatException("Failed to decode fixed64 number, Bad wire",
              field._name, field._tag);
        }
        _setNumber(field, _decodeFixed64(bytes, offset, length));
        break;
      case Type.sfixed64:
        if (wire != _Wire.num64.index) {
          throw FormatException("Failed to decode sfixed64 number, Bad wire",
              field._name, field._tag);
        }
        _setNumber(field, _decodeSfixed64(bytes, offset, length));
        break;
      case Type.float64:
        if (wire != _Wire.num64.index) {
          throw FormatException("Failed to decode float64 number, Bad wire",
              field._name, field._tag);
        }
        _setNumber(field, _decodeFloat64(bytes, offset, length));
        break;
      case Type.string:
        if (wire != _Wire.length.index) {
          throw FormatException(
              "Failed to decode string, Bad wire", field._name, field._tag);
        }
        _setString(field, _decodeString(bytes, offset, length));
        break;
      case Type.bytes:
        if (wire != _Wire.length.index) {
          throw FormatException(
              "Failed to decode bytes, Bad wire", field._name, field._tag);
        }
        _setBytes(field, _decodeBytes(bytes, offset, length));
        break;
      case Type.message:
        if (wire != _Wire.length.index) {
          throw FormatException(
              "Failed to decode message, Bad wire", field._name, field._tag);
        }
        if (field._attrs == null) {
          var message = DecoderMessage(field._value as List<Field>);
          message.decode(field, bytes, offset, offset + length);
          _setMessage(field, message);
        } else {
          var func = field._attrs as DecoderCreator;
          var message = func(this);
          message.decode(field, bytes, offset, offset + length);
          _setMessage(field, message);
        }
        break;
      default:
        assert(false);
    }
  }

  void _decodeRepeatedNode(Uint8List bytes, int offset, int end, Field field,
      int wire, int length, Field parent) {
    switch (field._type) {
      case Type.boolean:
        if (field._attrs == null || field._attrs as bool == true) {
          if (wire != _Wire.length.index) {
            throw FormatException("Failed to decode repeated boolean, Bad wire",
                field._name, field._tag);
          }
          var values = List<bool>();
          while (offset < end) {
            int count = _varintLength(bytes, offset, end - offset, 1);
            //length always is 1.
            if (count != 1 || offset + count > end) {
              throw FormatException(
                  "Failed to decode packed boolean, Bad length",
                  field._name,
                  field._tag);
            }
            values.add(_decodeBoolean(bytes, offset, count));
            offset += count;
          }
          _setRepeatedBool(field, values);
        } else {
          if (wire != _Wire.varint.index) {
            throw FormatException("Failed to decode repeated boolean, Bad wire",
                field._name, field._tag);
          }
          if (length != 1) {
            throw FormatException("Failed to decode boolean, Bad length",
                field._name, field._tag);
          }
          _addBool(field, _decodeBoolean(bytes, offset, length));
        }
        break;
      case Type.enumerated:
      case Type.uint32:
      case Type.int32:
      case Type.sint32:
        if (field._attrs == null || field._attrs as bool == true) {
          if (wire != _Wire.length.index) {
            throw FormatException(
                "Failed to decode number repeated varint32 number, Bad wire",
                field._name,
                field._tag);
          }
          var values = List<num>();
          while (offset < end) {
            int count = _varintLength(bytes, offset, end - offset, 10);
            if (count == -1 || offset + count > end) {
              throw FormatException(
                  "Failed to decode packed varint32 number, Bad length",
                  field._name,
                  field._tag);
            }
            if (field._type == Type.sint32) {
              values.add(_unzigzag32(_decodeUint32(bytes, offset, count)));
            } else if (field._type == Type.int32) {
              //FIMEME: only as Uint64 can get right value.
              values.add(_decodeUint64(bytes, offset, count));
            } else {
              values.add(_decodeUint32(bytes, offset, count));
            }
            offset += count;
          }
          _setRepeatedNumber(field, values);
        } else {
          if (wire != _Wire.varint.index) {
            throw FormatException("Failed to decode repeated boolean, Bad wire",
                field._name, field._tag);
          }
          if (field._type == Type.sint32) {
            _addNumber(field, _unzigzag32(_decodeUint32(bytes, offset, length)));
          } else if (field._type == Type.int32) {
            //FIMEME: only as Uint64 can get right value.
            _addNumber(field, _decodeUint64(bytes, offset, length));
          } else {
            _addNumber(field, _decodeUint32(bytes, offset, length));
          }
        }
        break;
      case Type.fixed32:
      case Type.sfixed32:
      case Type.float32:
        if (field._attrs == null || field._attrs as bool == true) {
          if (wire != _Wire.length.index) {
            throw FormatException(
                "Failed to decode repeated fixed32 number, Bad wire",
                field._name,
                field._tag);
          }
          var values = List<num>();
          int count = 4;
          while (offset < end) {
            if (offset + count > end) {
              throw FormatException(
                  "Failed to decode packed fixed32 number, bad length",
                  field._name,
                  field._tag);
            }
            if (field._type == Type.fixed32) {
              values.add(_decodeFixed32(bytes, offset, count));
            } else if (field._type == Type.sfixed32) {
              values.add(_decodeSfixed32(bytes, offset, count));
            } else {
              values.add(_decodeFloat32(bytes, offset, count));
            }
            offset += count;
          }
          _setRepeatedNumber(field, values);
        } else {
          if (wire != _Wire.num32.index) {
            throw FormatException(
                "Failed to decode repeated fixed32 number, Bad wire",
                field._name,
                field._tag);
          }
          if (field._type == Type.fixed32) {
            _addNumber(field, _decodeFixed32(bytes, offset, length));
          } else if (field._type == Type.sfixed32) {
            _addNumber(field, _decodeSfixed32(bytes, offset, length));
          } else {
            _addNumber(field, _decodeFloat32(bytes, offset, length));
          }
        }
        break;
      case Type.int64:
      case Type.sint64:
      case Type.uint64:
        if (field._attrs == null || field._attrs as bool == true) {
          if (wire != _Wire.length.index) {
            throw FormatException(
                "Failed to decode repeated varint64 number, Bad wire",
                field._name,
                field._tag);
          }
          var values = List<num>();
          while (offset < end) {
            int count = _varintLength(bytes, offset, end - offset, 10);
            if (count == -1 || offset + count > end) {
              throw FormatException(
                  "Failed to decode packed varint64 number, Bad length",
                  field._name,
                  field._tag);
            }
            if (field._type == Type.sint64) {
              values.add(_unzigzag64(_decodeUint64(bytes, offset, count)));
            } else {
              values.add(_decodeUint64(bytes, offset, count));
            }
            offset += count;
          }
          _setRepeatedNumber(field, values);
        } else {
          if (wire != _Wire.varint.index) {
            throw FormatException(
                "Failed to decode repeated varint64 number, Bad wire",
                field._name,
                field._tag);
          }
          if (field._type == Type.sint64) {
            _addNumber(field, _unzigzag64(_decodeUint64(bytes, offset, length)));
          } else {
            _addNumber(field, _decodeUint64(bytes, offset, length));
          }
        }
        break;

      case Type.fixed64:
      case Type.sfixed64:
      case Type.float64:
        if (field._attrs == null || field._attrs as bool == true) {
          if (wire != _Wire.length.index) {
            throw FormatException("Failed to decode repeated fixed64, Bad wire",
                field._name, field._tag);
          }
          var values = List<num>();
          int count = 8;
          while (offset < end) {
            if (offset + count > end) {
              throw FormatException(
                  "Failed to decode packed fixed32 number, bad length",
                  field._name,
                  field._tag);
            }
            if (field._type == Type.fixed64) {
              values.add(_decodeFixed64(bytes, offset, count));
            } else if (field._type == Type.sfixed64) {
              values.add(_decodeSfixed64(bytes, offset, count));
            } else {
              values.add(_decodeFloat64(bytes, offset, count));
            }
            offset += count;
          }
          _setRepeatedNumber(field, values);
        } else {
          if (wire != _Wire.num64.index) {
            throw FormatException(
                "Failed to decode repeated fixed64 number, Bad wire",
                field._name,
                field._tag);
          }
          if (field._type == Type.fixed64) {
            _addNumber(field, _decodeFixed64(bytes, offset, length));
          } else if (field._type == Type.sfixed64) {
            _addNumber(field, _decodeSfixed64(bytes, offset, length));
          } else {
            _addNumber(field, _decodeFloat64(bytes, offset, length));
          }
        }
        break;

      case Type.string:
        if (wire != _Wire.length.index) {
          throw FormatException("Failed to decode repeated string, Bad wire",
              field._name, field._tag);
        }
        _addString(field, _decodeString(bytes, offset, length));
        break;

      case Type.bytes:
        if (wire != _Wire.length.index) {
          throw FormatException("Failed to decode repeated bytes, Bad wire",
              field._name, field._tag);
        }
        _addBytes(field, _decodeBytes(bytes, offset, length));
        break;

      case Type.message:
        if (wire != _Wire.length.index) {
          throw FormatException("Failed to decode repeated message, Bad wire",
              field._name, field._tag);
        }
        if (field._attrs == null) {
          var message = DecoderMessage(field._value as List<Field>);
          message.decode(field, bytes, offset, offset + length);
          _addMessage(field, message);
        } else {
          var func = field._attrs as DecoderCreator;
          var message = func(this);
          message.decode(field, bytes, offset, offset + length);
          _addMessage(field, message);
        }
        break;

      default:
        assert(false);
    }
  }

  Field _lookupField(int tag) {
    for (int index = 0; index < _fields.length; index++) {
      if (_fields[index]._tag == tag) {
        return _fields[index];
      }
    }
    return null;
  }

  dynamic get realObject => this;

  void review() {
    for (var field in _fields) {
      if (field._label == Label.required && !_nodes.containsKey(field)) {
        throw FormatException("Required field must be initialled with a value",
            field._name, field._tag);
      }
    }
  }

  static int _unzigzag32(int v) {
    if (v & 1 != 0) {
      return -(v >> 1) - 1;
    } else {
      return v >> 1;
    }
  }

  static int _unzigzag64(int v) {
    if (v & 1 != 0) {
      return -(v >> 1) - 1;
    } else {
      return v >> 1;
    }
  }

  static int _decodeUint32(Uint8List bytes, int offset, int length) {
    int value = bytes[offset] & 0x7f;
    if (length > 1) {
      value |= ((bytes[offset + 1] & 0x7f) << 7);
      if (length > 2) {
        value |= ((bytes[offset + 2] & 0x7f) << 14);
        if (length > 3) {
          value |= ((bytes[offset + 3] & 0x7f) << 21);
          if (length > 4) value |= (bytes[offset + 4] << 28);
        }
      }
    }
    return value;
  }

  static int _decodeFixed32(Uint8List data, int offset, int count) {
    var bd = data.buffer.asByteData(offset);
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    return bd.getUint32(0, Endian.little);
  }

  static int _decodeSfixed32(Uint8List data, int offset, int count) {
    var bd = data.buffer.asByteData(offset);
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    return bd.getInt32(0, Endian.little);
  }

  static double _decodeFloat32(Uint8List byteList, int offset, int count) {
    var bd = byteList.buffer.asByteData(offset);
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    return bd.getFloat32(0, Endian.little);
  }

  static int _decodeUint64(Uint8List bytes, int offset, int count) {
    int value;
    if (count < 5) {
      return _decodeUint32(bytes, offset, count);
    }
    value = ((bytes[offset] & 0x7f)) |
        ((bytes[offset + 1] & 0x7f) << 7) |
        ((bytes[offset + 2] & 0x7f) << 14) |
        ((bytes[offset + 3] & 0x7f) << 21);
    int shift = 28;
    for (int index = 4; index < count; index++) {
      value |= (bytes[offset + index] & 0x7f) << shift;
      shift += 7;
    }
    return value;
  }

  static int _decodeFixed64(Uint8List byteList, int offset, int size) {
    var byteData = byteList.buffer.asByteData(offset);
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    return byteData.getUint64(0, Endian.little);
  }

  static int _decodeSfixed64(Uint8List byteList, int offset, int size) {
    var byteData = byteList.buffer.asByteData(offset);
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    return byteData.getInt64(0, Endian.little);
  }

  static double _decodeFloat64(Uint8List byteList, int offset, int size) {
    var byteData = byteList.buffer.asByteData(offset);
    //FIXME:Why it using Litte Endia? Or using the host byte order?
    //When I using the network byte order, but get wrong result,
    //So I have to using Endian.little to decode it.
    return byteData.getFloat64(0, Endian.little);
  }

  static bool _decodeBoolean(Uint8List byteList, int offset, int count) {
    var byteData = byteList.buffer.asByteData(offset);
    return byteData.getUint8(0) == 0 ? false : true;
  }

  static int _decodeLength(Uint8List bytes, int offset, int size) {
    int count = size > 5 ? 5 : size;
    int shift = 0;
    int value = 0;
    for (int index = 0; index < count; index++) {
      if (bytes[offset + index] & 0x80 != 0) {
        value |= (bytes[offset + index] & 0x7f) << shift;
        shift += 7;
      } else {
        value |= bytes[offset + index] << shift;
        //low 32 bits is the value, hight 32bit is the byte count.
        value |= (index + 1) << 32;
        return value;
      }
    }
    //invalid length.
    return -1;
  }

  static int _decodeTag(Uint8List bytes, int offset, int length) {
    int tag = (bytes[offset] & 0x7f) >> 3;
    int wire = bytes[offset] & 7;
    int value = 0;
    //because the tag offen < 128?
    if ((bytes[offset] & 0x80) == 0) {
      //low 32 bit is tag, hign 32 bits is count and 3 bits wire.
      value = (1 << 3 | wire) << 32;
      return value | tag;
    }
    int shift = 4;
    int count = length > 5 ? 5 : length;
    for (int index = 1; index < count; index++) {
      offset += index;
      if (bytes[offset] & 0x80 != 0) {
        tag |= (bytes[offset] & 0x7f) << shift;
        shift += 7;
      } else {
        tag |= bytes[offset] << shift;
        //low 32 bit is tag, hign 32 bits is count and 3 bits wire.
        value = ((index + 1) << 3 | wire) << 32;
        return value | tag;
      }
    }
    //return error;
    return -1;
  }

  static int _varintLength(Uint8List bytes, int offset, int length, int max) {
    int count = length > max ? max : length;
    for (int index = 0; index < count; index++) {
      if (bytes[offset + index] & 0x80 == 0) {
        return index + 1;
      }
    }
    //return error.
    return -1;
  }

  static String _decodeString(Uint8List bytes, int offset, int length) {
    return utf8.decode(bytes.sublist(offset, offset + length));
  }

  static Uint8List _decodeBytes(Uint8List bytes, int offset, int length) {
    Uint8List value = Uint8List(length);
    for (int index = 0; index < length; index++) {
      value[index] = bytes[offset + index];
    }
    return value;
  }

  List<Fragment> _fragments;
}
