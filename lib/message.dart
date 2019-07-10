part of pbconv;

abstract class _Message {
  _Message(List<Field> fields) {
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
          _RepeatedBooleanNode node = result;
          return node == null ? null : node._values;
        } else {
          _BooleanNode node = result;
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
          _RepeatedNumberNode node = result;
          return node == null ? null : node._values;
        } else {
          _NumberNode node = result;
          if (node == null && field._label == Label.optional) {
            return field._value;
          } else {
            return node == null ? null : node._value;
          }
        }
        break;
      case Type.string:
        if (field._label == Label.repeated) {
          _RepeatedStringNode node = result;
          return node == null ? null : node._values;
        } else {
          _StringNode node = result;
          if (node == null && field._label == Label.optional) {
            return field._value;
          } else {
            return node == null ? null : node._value;
          }
        }
        break;
      case Type.bytes:
        if (field._label == Label.repeated) {
          _RepeatedBytesNode node = result;
          return node == null ? null : node._values;
        } else {
          _BytesNode node = result;
          if (node == null && field._label == Label.optional) {
            return field._value;
          } else {
            return node == null ? null : node._value;
          }
        }
        break;
      case Type.message:
        if (field._label == Label.repeated) {
          _RepeatedMessageNode node = result;
          return node == null ? null : node._values;
        } else {
          if (field._createDecoderFunc == null) {
            _MessageNode node = result;
            return node == null ? null : node._value;
          } else {
            _MessageNode node = result;
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
          _nodes[field] = _RepeatedBooleanNode(field, value);
        } else {
          assert(value is bool);
          _nodes[field] = _BooleanNode(field, value);
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
          _nodes[field] = _RepeatedNumberNode(field, value);
        } else {
          assert(value is num);
          _nodes[field] = _NumberNode(field, value);
        }
        break;
      case Type.string:
        if (field._label == Label.repeated) {
          assert(value is List<String>);
          _nodes[field] = _RepeatedStringNode(field, value);
        } else {
          assert(value is String);
          _nodes[field] = _StringNode(field, value);
        }
        break;
      case Type.bytes:
        if (field._label == Label.repeated) {
          assert(value is List<Uint8List>);
          _nodes[field] = _RepeatedBytesNode(field, value);
        } else {
          assert(value is Uint8List);
          _nodes[field] = _BytesNode(field, value);
        }
        break;
      case Type.message:
        if (field._label == Label.repeated) {
          assert(value is List<_Message>);
          _nodes[field] = _RepeatedMessageNode(field, value);
        } else {
          assert(value is _Message);
          _nodes[field] = _MessageNode(field, value);
        }
        break;
      default:
        assert(false);
    }
  }

  void _addBool(Field field, bool value) {
    _RepeatedBooleanNode node = _nodes[field];
    if (node == null) {
      node = _RepeatedBooleanNode(field, List<bool>());
      _nodes[field] = node;
    }
    node._values.add(value);
  }

  void _addNumber(Field field, num value) {
    _RepeatedNumberNode node = _nodes[field];
    if (node == null) {
      node = _RepeatedNumberNode(field, List<num>());
      _nodes[field] = node;
    }
    node._values.add(value);
  }

  void _addString(Field field, String value) {
    _RepeatedStringNode node = _nodes[field];
    if (node == null) {
      node = _RepeatedStringNode(field, List<String>());
      _nodes[field] = node;
    }
    node._values.add(value);
  }

  void _addBytes(Field field, Uint8List value) {
    _RepeatedBytesNode node = _nodes[field];
    if (node == null) {
      node = _RepeatedBytesNode(field, List<Uint8List>());
      _nodes[field] = node;
    }
    node._values.add(value);
  }

  void _addMessage(Field field, _Message value) {
    _RepeatedMessageNode node = _nodes[field];
    if (node == null) {
      node = _RepeatedMessageNode(field, List<_Message>());
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
