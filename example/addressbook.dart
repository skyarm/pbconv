import "dart:io";
import 'dart:typed_data';

import "package:pbconv/pbconv.dart";

class Person {
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

  //this static method must be implemented.
  static DecoderMessage decoderCreator(dynamic value) {
    return _PersonDecoder();
  }

  //Declare the Person message fileds, include tag, name and type.
  static final List<Field> fields = [
    RequiredField(1, "ID", Type.uint32),
    RequiredField(2, "Name", Type.string),
    RepeatedField(3, "Emails", Type.string)
  ];
}

class _PersonEncoder extends EncoderMessage {
  _PersonEncoder(Person person) : super(Person.fields) {
    this[Person.fields[0]] = person._id;
    this[Person.fields[1]] = person._name;
    this[Person.fields[2]] = person._emails;
  }
}

class _PersonDecoder extends DecoderMessage {
  _PersonDecoder() : super(Person.fields);
  void decode(Field parent, Uint8List bytes, int offset, int end) {
    super.decode(parent, bytes, offset, end);
    _person = Person(
        this[Person.fields[0]] as int,
        this[Person.fields[1]] as String,
        this[Person.fields[2]] as List<String>);
  }

  Person get realObject => _person;

  Person _person;
}

class RepeatedPersonField extends Field {
  RepeatedPersonField(int tag, String name)
      : super(tag, name, Label.repeated, Type.message,
            value: Person.fields, attrs: Person.decoderCreator);
}

//Addressbook
class Addressbook {
  Addressbook() {
    _persons = List<Person>();
  }

  void addPerson(Person person) {
    _persons.add(person);
  }

  static EncoderMessage encoderMessage(Addressbook addressbook) {
    return _AddressbookEncoder(addressbook);
  }

  static DecoderMessage decoderMessage() {
    return _AddressbookDecoder();
  }

  static final List<Field> fields = [RepeatedPersonField(1, "Person")];

  List<Person> _persons;
}

//Implements _AddressbookEncoder, It will initial encoder data.
class _AddressbookEncoder extends EncoderMessage {
  _AddressbookEncoder(Addressbook addressbook) : super(Addressbook.fields) {
    var encoders = List<_PersonEncoder>();
    for (var person in addressbook._persons) {
      encoders.add(Person.createEncoder(person) as _PersonEncoder);
    }
    this[Addressbook.fields[0]] = encoders;
  }
}

//Implements _AddressbookDecoder, it is used to fetch data from Decoder.
class _AddressbookDecoder extends DecoderMessage {
  _AddressbookDecoder() : super(Addressbook.fields) {
    _addressbook._persons = List<Person>();
  }
  void decode(Field parent, Uint8List bytes, int offset, int end) {
    super.decode(parent, bytes, offset, end);
    _addressbook._persons.add(this[Addressbook.fields[0]] as Person);
  }

  Addressbook get realObject => _addressbook;

  Addressbook _addressbook;
}

main() {
  String filename = "./addressbook.bin";
  File file = File(filename);
  //if the file isn't exists.
  if (!file.existsSync()) {
    var addressbook = Addressbook();
    //add person to addressbook.
    addressbook
        .addPerson(Person(1, "Tom", ["tom@example1.com", "tom@example2.com"]));
    addressbook.addPerson(
        Person(2, "Thomas", ["thomas@example1.com", "thomas@example2.com"]));
    
    //now convert the addressbook message to binary bytes.
    var proto = protobuf.encode(Addressbook.encoderMessage(addressbook));

    file.writeAsBytesSync(proto.bytes);
    print("Now the binary file $filename has been created.");
  } else {
    var bytes = file.readAsBytesSync();
    print(bytes);
    DecoderMessage message =
        protobuf.decode(ProtoBytes(Addressbook.fields, bytes as Uint8List))
            as DecoderMessage;
    //decoderMessage.toString() return XML debug message, but the message hasn't root node.
    //it is used for debug only.
    print(message.toString());

    //This section show that how to access Message member.
    for (var person in message[Addressbook.fields[0]]) {
      print("Person:");
      print("\tID: ${person[Person.fields[0]]}");
      print("\tName: ${person[Person.fields[1]]}");
      print("\tEmails:");
      for (var email in person[Person.fields[2]]) {
        print("\t\t$email");
      }
    }
  }
}
