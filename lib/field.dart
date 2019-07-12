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

typedef DecoderCreator = DecoderMessage Function(dynamic value);

class Field {
  Field(int tag, String name, Label label, Type type,
      {dynamic value, dynamic attrs}) {
    _tag = tag;
    _name = name;
    _label = label;
    _type = type;
    _value = value;
    _attrs = attrs;
    assert(_review());
  }

  bool _review() {
    //the tag must be 32bit unsigned int value.
    if (_tag < 0 || _tag > 0xffffffff) {
      return false;
    }
    if (_value == null) {
      if (_type == Type.message) {
        return false;
      }
    } else {
      if (_type == Type.message) {
        if (_value is! List<Field>) {
          return false;
        }
      } else {
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
    }

    if (_attrs != null) {
      switch (_type) {
        case Type.message:
          if (_attrs is! DecoderCreator) {
            return false;
          }
          break;
        case Type.bytes:
        case Type.string:
          return false;
          break;
        default:
          if (_attrs is! bool) {
            return false;
          }
          break;
      }
    }
    return true;
  }

  String _name;
  int _tag;
  Label _label;
  Type _type;
  dynamic _value;
  dynamic _attrs;

  get hashCode => _tag;
  bool operator ==(dynamic other) => this.hashCode == other.hashCode;
}

class RequiredField extends Field {
  RequiredField(int tag, String name, Type type)
      : super(tag, name, Label.required, type, value: null);
}

class RepeatedField extends Field {
  RepeatedField(int tag, String name, Type type)
      : super(tag, name, Label.repeated, type, value: null);
}

class OptionalField extends Field {
  OptionalField(int tag, String name, Type type, [dynamic value])
      : super(tag, name, Label.optional, type, value: value);
}

class RequiredMessage extends Field {
  RequiredMessage(int tag, String name, List<Field> fields)
      : super(tag, name, Label.required, Type.message,
            value: fields);
}

class OptionalMessage extends Field {
  OptionalMessage(int tag, String name, List<Field> fields)
      : super(tag, name, Label.optional, Type.message,
            value: fields);
}

class RepeatedMessage extends Field {
  RepeatedMessage(int tag, String name, List<Field> fields)
      : super(tag, name, Label.repeated, Type.message,
            value: fields);
}
