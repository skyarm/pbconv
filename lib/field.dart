//
//
//
//
part of pbconv;

enum Label { required, optional, repeated }

enum Type {
  int32,
  sint32,
  sfixed32,
  int64,
  sint64,
  sfixed64,
  uint32,
  fixed32,
  uint64,
  fixed64,
  float32,
  float64,
  boolean,
  enumerated,
  string,
  bytes,
  message
}

typedef CreateDecoderFunc = DecoderMessage Function();

class Field {
  Field(int tag, String name, Label label, Type type,
      {dynamic value, CreateDecoderFunc func, bool packed = false}) {
    _tag = tag;
    _name = name;
    _label = label;
    _type = type;
    _value = value;
    _packed = packed;
    _func = func;
    assert(_review());
  }

  bool _review() {
    //the tag must be 32bit unsigned int value.
    if (_tag < 0 || _tag > 0xffffffff) {
      return false;
    }
    //RequiredNode and OptionalNode cann't be packed.
    if (_packed) {
      if (_label == Label.required || _label == Label.optional) {
        return false;
      }
      //Packed repeated field cann't be string , bytes, message type.
      if (_type == Type.string ||
          _type == Type.bytes ||
          _type == Type.message) {
        return false;
      }
    }
    if (_value != null && _type != Type.message) {
      //Except message type, Other required and repeated type's value must be null.
      if (_label == Label.required || _label == Label.repeated) {
        return false;
      }
      switch (_type) {
        case Type.boolean:
          if (!(_value is bool)) {
            return false;
          }
          break;
        case Type.enumerated:
        case Type.fixed32:
        case Type.fixed64:
        case Type.float32:
        case Type.float64:
        case Type.int32:
        case Type.int64:
        case Type.sfixed32:
        case Type.sfixed64:
        case Type.sint32:
        case Type.sint64:
        case Type.uint32:
        case Type.uint64:
          if (!(_value is num)) {
            return false;
          }
          break;
        case Type.string:
          if (!(_value is String)) {
            return false;
          }
          break;
        case Type.bytes: //bytes no default value?
          return false;
          break;
        case Type.message:
          if (!(_value is List<Field>)) {
            return false;
          }
          break;
        default:
          return false;
      }
    }
    //If field type is message, The value must be instance of Message field or message field list.
    if (_type == Type.message) {
      if (_value == null) {
        return false;
      } else {
        //Not recheadable?
        if (!(_value is List<Field>)) {
          return false;
        }
      }
    }
    if (_func != null) {
      if (_type != Type.message) {
        //FIXME:Can decoderFunc be used to other type?
        return false;
      }
    }
    return true;
  }

  String _name;
  int _tag;
  Label _label;
  Type _type;
  dynamic _value;
  bool _packed;
  CreateDecoderFunc _func;

  get hashCode => _tag;
  bool operator ==(dynamic other) => this.hashCode == other.hashCode;
}

class RequiredField extends Field {
  RequiredField(int tag, String name, Type type)
      : super(tag, name, Label.required, type, value: null, packed: false);
}

class RepeatedField extends Field {
  RepeatedField(int tag, String name, Type type, [bool packed = false])
      : super(tag, name, Label.repeated, type, value: null, packed: packed);
}

class OptionalField extends Field {
  OptionalField(int tag, String name, Type type, [dynamic value])
      : super(tag, name, Label.optional, type, value: value, packed: false);
}

class MessageField extends Field {
  MessageField(int tag, String name, Label label, List<Field> fields)
      : super(tag, name, label, Type.message, value: fields, packed: false);
}

class RequiredMessage extends Field {
  RequiredMessage(int tag, String name, List<Field> fields)
      : super(tag, name, Label.required, Type.message,
            value: fields, packed: false);
}

class OptionalMessage extends Field {
  OptionalMessage(int tag, String name, List<Field> fields)
      : super(tag, name, Label.optional, Type.message,
            value: fields, packed: false);
}

class RepeatedMessage extends Field {
  RepeatedMessage(int tag, String name, List<Field> fields)
      : super(tag, name, Label.repeated, Type.message,
            value: fields, packed: false);
}
