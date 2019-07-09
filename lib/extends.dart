part of pbconv;

class Timestamp {
  static final List<Field> fields = [
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
            value: Timestamp.fields,
            createDecoderFunc: Timestamp.createDecoder) {}
}

class OptionalTimestamp extends Field {
  OptionalTimestamp(int tag, String name)
      : super(tag, name, Label.optional, Type.message,
            value: Timestamp.fields,
            createDecoderFunc: Timestamp.createDecoder) {}
}

class RepeatedTimestamp extends Field {
  RepeatedTimestamp(int tag, String name)
      : super(tag, name, Label.repeated, Type.message,
            value: Timestamp.fields,
            createDecoderFunc: Timestamp.createDecoder) {}
}

class _TimestampEncoder extends EncoderMessage {
  _TimestampEncoder([DateTime value = null]) : super(Timestamp.fields) {
    if (value == null) {
      value = DateTime.now();
    }
    int seconds =
        value.microsecondsSinceEpoch ~/ Duration.microsecondsPerSecond;
    int nanos =
        value.microsecondsSinceEpoch - seconds * Duration.microsecondsPerSecond;
    this[Timestamp.fields[0]] = seconds;
    this[Timestamp.fields[1]] = nanos;
  }
}

class _TimestampDecoder extends DecoderMessage {
  _TimestampDecoder() : super(Timestamp.fields) {}

  void decode(Field parent, Uint8List bytes, int offset, int end) {
    super.decode(parent, bytes, offset, end);

    int seconds = this[Timestamp.fields[0]];
    int nanos = this[Timestamp.fields[1]];

    _datetime = DateTime.fromMicrosecondsSinceEpoch(
        seconds * Duration.microsecondsPerSecond + nanos);
  }

  DateTime get realObject => _datetime;

  String toString() {
    return _datetime.toString();
  }

  DateTime _datetime;
}

class Timespan {
  static final List<Field> fields = [
    RequiredField(1, "Seconds", Type.int64),
    RequiredField(2, "Nanos", Type.int32),
  ];

  static EncoderMessage createEncoder(Duration value) {
    return _DurationEncoder(value);
  }

  static DecoderMessage createDecoder() {
    return _DurationDecoder();
  }
}

class RequiredDuration extends Field {
  RequiredDuration(int tag, String name)
      : super(tag, name, Label.required, Type.message,
            value: Timespan.fields,
            createDecoderFunc: Timespan.createDecoder) {}
}

class OptionalDuration extends Field {
  OptionalDuration(int tag, String name)
      : super(tag, name, Label.optional, Type.message,
            value: Timespan.fields,
            createDecoderFunc: Timespan.createDecoder) {}
}

class RepeatedDuration extends Field {
  RepeatedDuration(int tag, String name)
      : super(tag, name, Label.repeated, Type.message,
            value: Timespan.fields,
            createDecoderFunc: Timespan.createDecoder) {}
}

class _DurationEncoder extends EncoderMessage {
  _DurationEncoder([Duration value = null]) : super(Timespan.fields) {
    if (value == null) {
      value = Duration();
    }
    int seconds = value.inSeconds;
    this[Timespan.fields[0]] = seconds;
    this[Timespan.fields[1]] = value.inMicroseconds - seconds * Duration.microsecondsPerSecond;
  }
}

class _DurationDecoder extends DecoderMessage {
  _DurationDecoder() : super(Timespan.fields) {}

  void decode(Field parent, Uint8List bytes, int offset, int end) {
    super.decode(parent, bytes, offset, end);

    int seconds = this[Timespan.fields[0]];
    int nanos = this[Timespan.fields[1]];

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
