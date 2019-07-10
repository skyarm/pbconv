import "dart:io";
import 'dart:typed_data';

import "package:pbconv/pbconv.dart";

class Person {
  static final List<Field> fields = [
    RequiredField(1, "id", Type.uint32),
    RequiredField(2, "name", Type.string),
    RepeatedField(3, "emails", Type.string)
  ];

  Person(int id, String name, List<String> emails) {
    _id = id;
    _name = name;
    _emails = emails;
  }

  int _id;
  String _name;
  List<String> _emails;

  static EncoderMessage createEncoder(Person person) {
    return _PersonEncoder(person);
  }

  static DecoderMessage createDecoder() {
    return _PersonDecoder();
  }
}

class _PersonEncoder extends EncoderMessage {
  _PersonEncoder(Person person) : super(Person.fields) {
    this[Person.fields[0]] = person._id;
    this[Person.fields[1]] = person._name;
    this[Person.fields[2]] = person._emails;
  }
}

class _PersonDecoder extends DecoderMessage {
  _PersonDecoder() : super(Person.fields) {}
  void decode(Field parent, Uint8List bytes, int offset, int end) {
    super.decode(parent, bytes, offset, end);

    _person = Person(
        this[Person.fields[0]], this[Person.fields[1]], this[Person.fields[2]]);
  }

  Person get realObject => _person;

  Person _person;
}

class RepeatedPersonField extends Field {
  RepeatedPersonField(int tag, String name)
      : super(tag, name, Label.repeated, Type.message,
            value: Person.fields, createDecoderFunc: Person.createDecoder) {}
}

class Addressbook {
  static final List<Field> fields = [RepeatedPersonField(1, "Person")];
  Addressbook() {
    _persons = List<Person>();
  }

  void addPerson(Person person) {
    _persons.add(person);
  }

  static EncoderMessage createEncoder(Addressbook addressbook) {
    return _AddressbookEncoder(addressbook);
  }

  static DecoderMessage createDecoder() {
    return _AddressbookDecoder();
  }

  List<Person> _persons;
}

class _AddressbookEncoder extends EncoderMessage {
  _AddressbookEncoder(Addressbook addressbook) : super(Addressbook.fields) {
    var encoders = List<_PersonEncoder>();
    for (var person in addressbook._persons) {
      encoders.add(Person.createEncoder(person));
    }
    this[Addressbook.fields[0]] = encoders;
  }
}

class _AddressbookDecoder extends DecoderMessage {
  _AddressbookDecoder() : super(Addressbook.fields) {
    _addressbook._persons = List<Person>();
  }
  void decode(Field parent, Uint8List bytes, int offset, int end) {
    super.decode(parent, bytes, offset, end);
    _addressbook._persons.add(this[Addressbook.fields[0]]);
  }

  Addressbook get realObject => _addressbook;

  Addressbook _addressbook;
}

main() {
  File file = File("./addressbook.pbb");
  if (!file.existsSync()) {
    var addressbook = Addressbook();
    addressbook
        .addPerson(Person(1, "Tom", ["tom@example1.com", "tom@example2.com"]));
    addressbook.addPerson(
        Person(2, "Thomas", ["thomas@example1.com", "thomas@example2.com"]));

    var encoder = ProtobufEncoder();
    var bytes = encoder.convert(Addressbook.createEncoder(addressbook));

    file.writeAsBytesSync(bytes);
  } else {
    var bytes = file.readAsBytesSync();
    print(bytes);
    ProtobufDecoder decoder = ProtobufDecoder(Addressbook.fields);
    DecoderMessage decoderMessage = decoder.convert(bytes);
    print(decoderMessage.toString());
  }
}
