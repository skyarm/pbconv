part of pbconv;

class Timestamp {
  static final List<Field> _fields = [
    RequiredField(1, "Seconds", Type.int64),
    RequiredField(2, "Nanos", Type.int32),
  ];
  static EncoderMessage createEncoder(DateTime value) {
    return _TimestampEncoder(value);
  }

  static DecoderMessage createDecoder() {
    return _TimestampDecoder();
  }
}

class RequiredTimestamp extends Field {
  RequiredTimestamp(int tag, String name)
      : super(tag, name, Label.required, Type.message,
            value: Timestamp._fields,
            createDecoderFunc: Timestamp.createDecoder);
}

class OptionalTimestamp extends Field {
  OptionalTimestamp(int tag, String name)
      : super(tag, name, Label.optional, Type.message,
            value: Timestamp._fields,
            createDecoderFunc: Timestamp.createDecoder);
}

class RepeatedTimestamp extends Field {
  RepeatedTimestamp(int tag, String name)
      : super(tag, name, Label.repeated, Type.message,
            value: Timestamp._fields,
            createDecoderFunc: Timestamp.createDecoder);
}

class _TimestampEncoder extends EncoderMessage {
  _TimestampEncoder([DateTime value]) : super(Timestamp._fields) {
    if (value == null) {
      value = DateTime.now();
    }
    int seconds =
        value.microsecondsSinceEpoch ~/ Duration.microsecondsPerSecond;
    int nanos =
        value.microsecondsSinceEpoch - seconds * Duration.microsecondsPerSecond;
        
    this[Timestamp._fields[0]] = seconds;
    this[Timestamp._fields[1]] = nanos;
  }
}

class _TimestampDecoder extends DecoderMessage {
  _TimestampDecoder() : super(Timestamp._fields);

  void decode(Field parent, Uint8List bytes, int offset, int end) {
    super.decode(parent, bytes, offset, end);

    int seconds = this[_fields[0]] as int;
    int nanos = this[_fields[1]] as int;

    _dateTime = DateTime.fromMicrosecondsSinceEpoch(
        seconds * Duration.microsecondsPerSecond + nanos);
  }

  DateTime get realObject => _dateTime;

  String toString() {
    return _dateTime.toString();
  }

  DateTime _dateTime;
}

class Timespan {
  static final List<Field> fields = [
    RequiredField(1, "Seconds", Type.int64),
    RequiredField(2, "Nanos", Type.int32),
  ];

  static EncoderMessage createEncoder(Duration value) {
    return _TimespanEncoder(value);
  }

  static DecoderMessage createDecoder() {
    return _TimespanDecoder();
  }
}

class RequiredTimespan extends Field {
  RequiredTimespan(int tag, String name)
      : super(tag, name, Label.required, Type.message,
            value: Timespan.fields,
            createDecoderFunc: Timespan.createDecoder);
}

class OptionalTimespan extends Field {
  OptionalTimespan(int tag, String name)
      : super(tag, name, Label.optional, Type.message,
            value: Timespan.fields,
            createDecoderFunc: Timespan.createDecoder);
}

class RepeatedTimespan extends Field {
  RepeatedTimespan(int tag, String name)
      : super(tag, name, Label.repeated, Type.message,
            value: Timespan.fields,
            createDecoderFunc: Timespan.createDecoder);
}

class _TimespanEncoder extends EncoderMessage {
  _TimespanEncoder(Duration value) : super(Timespan.fields) {
    assert(value != null);
    int seconds = value.inSeconds;
    this[Timespan.fields[0]] = seconds;
    this[Timespan.fields[1]] = value.inMicroseconds - seconds * Duration.microsecondsPerSecond;
  }
}

class _TimespanDecoder extends DecoderMessage {
  _TimespanDecoder() : super(Timespan.fields);

  void decode(Field parent, Uint8List bytes, int offset, int end) {
    super.decode(parent, bytes, offset, end);

    int seconds = this[_fields[0]] as int;
    int nanos = this[_fields[1]] as int;

    int days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;

    int hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;

    int minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= hours * Duration.secondsPerMinute;

    int milliseconds = nanos ~/ Duration.microsecondsPerMillisecond;
    nanos -= milliseconds * Duration.microsecondsPerMillisecond;
    int microseconds = nanos;

    _duration = Duration(
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
        microseconds: microseconds);
  }

  Duration get realObject => _duration;
  
  String toString() {
    return _duration.toString();
  }
  
  Duration _duration;
}
