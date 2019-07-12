part of pbconv;

abstract class Message {
  Message(List<Field> fields) {
    assert(tagsReview(fields), "Tag ID is duplicated");
    _fields = fields;
    _nodes = HashMap<Field, _Node>();
  }

  static bool tagsReview(List<Field> fields) {
    Set<int> tags = Set<int>();
    for (var field in fields) {
      if (tags.contains(field._tag)) {
        return false;
      } else {
        tags.add(field._tag);
      }
    }
    return true;
  }

  dynamic operator [](Field field) {
    _Node result = _nodes[field];

    switch (field._type) {
      case Type.boolean:
        if (field._label == Label.repeated) {
          var node = result as _RepeatedBooleanNode;
          return node == null ? null : node._values;
        } else {
          var node = result as _BooleanNode;
          if (node == null && field._label == Label.optional) {
            return field._value;
          } else {
            return node == null ? null : node._value;
          }
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
        if (field._label == Label.repeated) {
          var node = result as _RepeatedNumberNode;
          return node == null ? null : node._values;
        } else {
          var node = result as _NumberNode;
          if (node == null && field._label == Label.optional) {
            return field._value;
          } else {
            return node == null ? null : node._value;
          }
        }
        break;
      case Type.string:
        if (field._label == Label.repeated) {
          var node = result as _RepeatedStringNode;
          return node == null ? null : node._values;
        } else {
          var node = result as _StringNode;
          if (node == null && field._label == Label.optional) {
            return field._value;
          } else {
            return node == null ? null : node._value;
          }
        }
        break;
      case Type.bytes:
        if (field._label == Label.repeated) {
          var node = result as _RepeatedBytesNode;
          return node == null ? null : node._values;
        } else {
          var node = result as _BytesNode;
          if (node == null && field._label == Label.optional) {
            return field._value;
          } else {
            return node == null ? null : node._value;
          }
        }
        break;
      case Type.message:
        if (field._label == Label.repeated) {
          var node = result as _RepeatedMessageNode;
          return node == null ? null : node._values;
        } else {
          if (field._attrs == null) {
            var node = result as _MessageNode;
            return node == null ? null : node._value;
          } else {
            var node = result as _MessageNode;
            return node == null ? null : node._value.realObject;
          }
        }
        break;
      default:
        assert(false);
    }
  }

  operator []=(Field field, dynamic value) {
    switch (field._type) {
      case Type.boolean:
        if (field._label == Label.repeated) {
          assert(value is List<bool>);
          _nodes[field] = _RepeatedBooleanNode(field, value as List<bool>);
        } else {
          assert(value is bool);
          _nodes[field] = _BooleanNode(field, value as bool);
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
        if (field._label == Label.repeated) {
          assert(value is List<num>);
          _nodes[field] = _RepeatedNumberNode(field, value as List<num>);
        } else {
          assert(value is num);
          _nodes[field] = _NumberNode(field, value as num);
        }
        break;
      case Type.string:
        if (field._label == Label.repeated) {
          assert(value is List<String>);
          _nodes[field] = _RepeatedStringNode(field, value as List<String>);
        } else {
          assert(value is String);
          _nodes[field] = _StringNode(field, value as String);
        }
        break;
      case Type.bytes:
        if (field._label == Label.repeated) {
          assert(value is List<Uint8List>);
          _nodes[field] = _RepeatedBytesNode(field, value as List<Uint8List>);
        } else {
          assert(value is Uint8List);
          _nodes[field] = _BytesNode(field, value as Uint8List);
        }
        break;
      case Type.message:
        if (field._label == Label.repeated) {
          assert(value is List<Message>);
          _nodes[field] = _RepeatedMessageNode(field, value as List<Message>);
        } else {
          assert(value is Message);
          _nodes[field] = _MessageNode(field, value as Message);
        }
        break;
      default:
        assert(false);
    }
  }

  void _setBool(Field field, bool value) {
    var node = _nodes[field] as _BooleanNode;
    if (node == null) {
      node = _BooleanNode(field, value);
      _nodes[field] = node;
    } else {
      throw FormatException("Duplicated node", field._name, field._tag);
    }
  }

  void _setRepeatedBool(Field field, List<bool> values) {
    var node = _nodes[field] as _RepeatedBooleanNode;
    if (node == null) {
      node = _RepeatedBooleanNode(field, List<bool>());
      _nodes[field] = node;
    } else {
      throw FormatException("Duplicated node", field._name, field._tag);
    }
  }


  void _addBool(Field field, bool value) {
    var node = _nodes[field] as _RepeatedBooleanNode;
    if (node == null) {
      node = _RepeatedBooleanNode(field, List<bool>());
      _nodes[field] = node;
    }
    node._values.add(value);
  }

  void _setNumber(Field field, num value) {
    var node = _nodes[field] as _NumberNode;
    if (node == null) {
      node = _NumberNode(field, value);
      _nodes[field] = node;
    } else {
      throw FormatException("Duplicated node", field._name, field._tag);
    }
  }

  void _setRepeatedNumber(Field field, List<num> values) {
    var node = _nodes[field] as _RepeatedNumberNode;
    if (node == null) {
      node = _RepeatedNumberNode(field, List<num>());
      _nodes[field] = node;
    } else {
      throw FormatException("Duplicated node", field._name, field._tag);
    }
  }
  

  void _addNumber(Field field, num value) {
    var node = _nodes[field] as _RepeatedNumberNode;
    if (node == null) {
      node = _RepeatedNumberNode(field, List<num>());
      _nodes[field] = node;
    }
    node._values.add(value);
  }


  void _setString(Field field, String value) {
    var node = _nodes[field] as _StringNode;
    if (node == null) {
      node = _StringNode(field, value);
      _nodes[field] = node;
    } else {
      throw FormatException("Duplicated node", field._name, field._tag);
    }
  }

  void _addString(Field field, String value) {
    var node = _nodes[field] as _RepeatedStringNode;
    if (node == null) {
      node = _RepeatedStringNode(field, List<String>());
      _nodes[field] = node;
    }
    node._values.add(value);
  }

  void _setBytes(Field field, Uint8List value) {
    var node = _nodes[field] as _BytesNode;
    if (node == null) {
      node = _BytesNode(field, value);
      _nodes[field] = node;
    } else {
      throw FormatException("Duplicated node", field._name, field._tag);
    }
  }

  void _addBytes(Field field, Uint8List value) {
    var node = _nodes[field] as _RepeatedBytesNode;
    if (node == null) {
      node = _RepeatedBytesNode(field, List<Uint8List>());
      _nodes[field] = node;
    }
    node._values.add(value);
  }

  void _setMessage(Field field, Message value) {
    var node = _nodes[field] as _MessageNode;
    if (node == null) {
      node = _MessageNode(field, value);
      _nodes[field] = node;
    } else {
      throw FormatException("Duplicated node", field._name, field._tag);
    }
  }


  void _addMessage(Field field, Message value) {
    var node = _nodes[field] as _RepeatedMessageNode;
    if (node == null) {
      node = _RepeatedMessageNode(field, List<Message>());
      _nodes[field] = node;
    }
    node._values.add(value);
  }

  dynamic get realObject {
    return null;
  }

  String toString() {
    String xml = "";
    for (_Node node in _nodes.values) {
      xml += node.toString();
    }
    return xml;
  }

  List<Field> _fields;
  HashMap<Field, _Node> _nodes;
}
