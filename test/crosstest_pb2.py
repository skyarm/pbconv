# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: crosstest.proto

import sys
_b=sys.version_info[0]<3 and (lambda x:x) or (lambda x:x.encode('latin1'))
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from google.protobuf import reflection as _reflection
from google.protobuf import symbol_database as _symbol_database
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()




DESCRIPTOR = _descriptor.FileDescriptor(
  name='crosstest.proto',
  package='crosstest',
  syntax='proto2',
  serialized_options=None,
  serialized_pb=_b('\n\x0f\x63rosstest.proto\x12\tcrosstest\"+\n\tTimestamp\x12\x0f\n\x07seconds\x18\x01 \x02(\x03\x12\r\n\x05nanos\x18\x02 \x02(\x05\"*\n\x08Timespan\x12\x0f\n\x07seconds\x18\x01 \x02(\x03\x12\r\n\x05nanos\x18\x02 \x02(\x05\"1\n\nCoordinate\x12\x11\n\tlongitude\x18\x01 \x02(\x01\x12\x10\n\x08latitude\x18\x02 \x02(\x01\"%\n\x05\x43hild\x12\r\n\x05node1\x18\x01 \x03(\t\x12\r\n\x05node2\x18\x02 \x02(\x11\"\xc3\x01\n\x04Root\x12\r\n\x05node1\x18\x01 \x02(\x05\x12\r\n\x05node2\x18\x02 \x03(\t\x12\r\n\x05node3\x18\x03 \x02(\x0c\x12\x1f\n\x05node4\x18\x04 \x02(\x0b\x32\x10.crosstest.Child\x12#\n\x05node5\x18\x05 \x02(\x0b\x32\x14.crosstest.Timestamp\x12$\n\x05node6\x18\x06 \x02(\x0b\x32\x15.crosstest.Coordinate\x12\"\n\x05node7\x18\x07 \x02(\x0b\x32\x13.crosstest.Timespan')
)




_TIMESTAMP = _descriptor.Descriptor(
  name='Timestamp',
  full_name='crosstest.Timestamp',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='seconds', full_name='crosstest.Timestamp.seconds', index=0,
      number=1, type=3, cpp_type=2, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='nanos', full_name='crosstest.Timestamp.nanos', index=1,
      number=2, type=5, cpp_type=1, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  serialized_options=None,
  is_extendable=False,
  syntax='proto2',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=30,
  serialized_end=73,
)


_TIMESPAN = _descriptor.Descriptor(
  name='Timespan',
  full_name='crosstest.Timespan',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='seconds', full_name='crosstest.Timespan.seconds', index=0,
      number=1, type=3, cpp_type=2, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='nanos', full_name='crosstest.Timespan.nanos', index=1,
      number=2, type=5, cpp_type=1, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  serialized_options=None,
  is_extendable=False,
  syntax='proto2',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=75,
  serialized_end=117,
)


_COORDINATE = _descriptor.Descriptor(
  name='Coordinate',
  full_name='crosstest.Coordinate',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='longitude', full_name='crosstest.Coordinate.longitude', index=0,
      number=1, type=1, cpp_type=5, label=2,
      has_default_value=False, default_value=float(0),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='latitude', full_name='crosstest.Coordinate.latitude', index=1,
      number=2, type=1, cpp_type=5, label=2,
      has_default_value=False, default_value=float(0),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  serialized_options=None,
  is_extendable=False,
  syntax='proto2',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=119,
  serialized_end=168,
)


_CHILD = _descriptor.Descriptor(
  name='Child',
  full_name='crosstest.Child',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='node1', full_name='crosstest.Child.node1', index=0,
      number=1, type=9, cpp_type=9, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='node2', full_name='crosstest.Child.node2', index=1,
      number=2, type=17, cpp_type=1, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  serialized_options=None,
  is_extendable=False,
  syntax='proto2',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=170,
  serialized_end=207,
)


_ROOT = _descriptor.Descriptor(
  name='Root',
  full_name='crosstest.Root',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='node1', full_name='crosstest.Root.node1', index=0,
      number=1, type=5, cpp_type=1, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='node2', full_name='crosstest.Root.node2', index=1,
      number=2, type=9, cpp_type=9, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='node3', full_name='crosstest.Root.node3', index=2,
      number=3, type=12, cpp_type=9, label=2,
      has_default_value=False, default_value=_b(""),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='node4', full_name='crosstest.Root.node4', index=3,
      number=4, type=11, cpp_type=10, label=2,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='node5', full_name='crosstest.Root.node5', index=4,
      number=5, type=11, cpp_type=10, label=2,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='node6', full_name='crosstest.Root.node6', index=5,
      number=6, type=11, cpp_type=10, label=2,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='node7', full_name='crosstest.Root.node7', index=6,
      number=7, type=11, cpp_type=10, label=2,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  serialized_options=None,
  is_extendable=False,
  syntax='proto2',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=210,
  serialized_end=405,
)

_ROOT.fields_by_name['node4'].message_type = _CHILD
_ROOT.fields_by_name['node5'].message_type = _TIMESTAMP
_ROOT.fields_by_name['node6'].message_type = _COORDINATE
_ROOT.fields_by_name['node7'].message_type = _TIMESPAN
DESCRIPTOR.message_types_by_name['Timestamp'] = _TIMESTAMP
DESCRIPTOR.message_types_by_name['Timespan'] = _TIMESPAN
DESCRIPTOR.message_types_by_name['Coordinate'] = _COORDINATE
DESCRIPTOR.message_types_by_name['Child'] = _CHILD
DESCRIPTOR.message_types_by_name['Root'] = _ROOT
_sym_db.RegisterFileDescriptor(DESCRIPTOR)

Timestamp = _reflection.GeneratedProtocolMessageType('Timestamp', (_message.Message,), {
  'DESCRIPTOR' : _TIMESTAMP,
  '__module__' : 'crosstest_pb2'
  # @@protoc_insertion_point(class_scope:crosstest.Timestamp)
  })
_sym_db.RegisterMessage(Timestamp)

Timespan = _reflection.GeneratedProtocolMessageType('Timespan', (_message.Message,), {
  'DESCRIPTOR' : _TIMESPAN,
  '__module__' : 'crosstest_pb2'
  # @@protoc_insertion_point(class_scope:crosstest.Timespan)
  })
_sym_db.RegisterMessage(Timespan)

Coordinate = _reflection.GeneratedProtocolMessageType('Coordinate', (_message.Message,), {
  'DESCRIPTOR' : _COORDINATE,
  '__module__' : 'crosstest_pb2'
  # @@protoc_insertion_point(class_scope:crosstest.Coordinate)
  })
_sym_db.RegisterMessage(Coordinate)

Child = _reflection.GeneratedProtocolMessageType('Child', (_message.Message,), {
  'DESCRIPTOR' : _CHILD,
  '__module__' : 'crosstest_pb2'
  # @@protoc_insertion_point(class_scope:crosstest.Child)
  })
_sym_db.RegisterMessage(Child)

Root = _reflection.GeneratedProtocolMessageType('Root', (_message.Message,), {
  'DESCRIPTOR' : _ROOT,
  '__module__' : 'crosstest_pb2'
  # @@protoc_insertion_point(class_scope:crosstest.Root)
  })
_sym_db.RegisterMessage(Root)


# @@protoc_insertion_point(module_scope)
