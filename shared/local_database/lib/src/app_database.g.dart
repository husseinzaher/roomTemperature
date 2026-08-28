// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReadingsTable extends Readings
    with TableInfo<$ReadingsTable, ReadingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _roomTemperatureCMeta = const VerificationMeta(
    'roomTemperatureC',
  );
  @override
  late final GeneratedColumn<double> roomTemperatureC = GeneratedColumn<double>(
    'room_temperature_c',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomTemperatureSourceMeta =
      const VerificationMeta('roomTemperatureSource');
  @override
  late final GeneratedColumn<String> roomTemperatureSource =
      GeneratedColumn<String>(
        'room_temperature_source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _outsideTemperatureCMeta =
      const VerificationMeta('outsideTemperatureC');
  @override
  late final GeneratedColumn<double> outsideTemperatureC =
      GeneratedColumn<double>(
        'outside_temperature_c',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roomTemperatureC,
    roomTemperatureSource,
    outsideTemperatureC,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('room_temperature_c')) {
      context.handle(
        _roomTemperatureCMeta,
        roomTemperatureC.isAcceptableOrUnknown(
          data['room_temperature_c']!,
          _roomTemperatureCMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roomTemperatureCMeta);
    }
    if (data.containsKey('room_temperature_source')) {
      context.handle(
        _roomTemperatureSourceMeta,
        roomTemperatureSource.isAcceptableOrUnknown(
          data['room_temperature_source']!,
          _roomTemperatureSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roomTemperatureSourceMeta);
    }
    if (data.containsKey('outside_temperature_c')) {
      context.handle(
        _outsideTemperatureCMeta,
        outsideTemperatureC.isAcceptableOrUnknown(
          data['outside_temperature_c']!,
          _outsideTemperatureCMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outsideTemperatureCMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      roomTemperatureC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}room_temperature_c'],
      )!,
      roomTemperatureSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_temperature_source'],
      )!,
      outsideTemperatureC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}outside_temperature_c'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $ReadingsTable createAlias(String alias) {
    return $ReadingsTable(attachedDatabase, alias);
  }
}

class ReadingRow extends DataClass implements Insertable<ReadingRow> {
  /// The surrogate primary key of this reading.
  final int id;

  /// The room temperature in Celsius.
  final double roomTemperatureC;

  /// The name of the `RoomTemperatureSource` enum value that produced
  /// [roomTemperatureC].
  final String roomTemperatureSource;

  /// The outside temperature in Celsius at the time of this reading.
  final double outsideTemperatureC;

  /// When this reading was taken.
  final DateTime recordedAt;
  const ReadingRow({
    required this.id,
    required this.roomTemperatureC,
    required this.roomTemperatureSource,
    required this.outsideTemperatureC,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['room_temperature_c'] = Variable<double>(roomTemperatureC);
    map['room_temperature_source'] = Variable<String>(roomTemperatureSource);
    map['outside_temperature_c'] = Variable<double>(outsideTemperatureC);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  ReadingsCompanion toCompanion(bool nullToAbsent) {
    return ReadingsCompanion(
      id: Value(id),
      roomTemperatureC: Value(roomTemperatureC),
      roomTemperatureSource: Value(roomTemperatureSource),
      outsideTemperatureC: Value(outsideTemperatureC),
      recordedAt: Value(recordedAt),
    );
  }

  factory ReadingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingRow(
      id: serializer.fromJson<int>(json['id']),
      roomTemperatureC: serializer.fromJson<double>(json['roomTemperatureC']),
      roomTemperatureSource: serializer.fromJson<String>(
        json['roomTemperatureSource'],
      ),
      outsideTemperatureC: serializer.fromJson<double>(
        json['outsideTemperatureC'],
      ),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roomTemperatureC': serializer.toJson<double>(roomTemperatureC),
      'roomTemperatureSource': serializer.toJson<String>(roomTemperatureSource),
      'outsideTemperatureC': serializer.toJson<double>(outsideTemperatureC),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  ReadingRow copyWith({
    int? id,
    double? roomTemperatureC,
    String? roomTemperatureSource,
    double? outsideTemperatureC,
    DateTime? recordedAt,
  }) => ReadingRow(
    id: id ?? this.id,
    roomTemperatureC: roomTemperatureC ?? this.roomTemperatureC,
    roomTemperatureSource: roomTemperatureSource ?? this.roomTemperatureSource,
    outsideTemperatureC: outsideTemperatureC ?? this.outsideTemperatureC,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  ReadingRow copyWithCompanion(ReadingsCompanion data) {
    return ReadingRow(
      id: data.id.present ? data.id.value : this.id,
      roomTemperatureC: data.roomTemperatureC.present
          ? data.roomTemperatureC.value
          : this.roomTemperatureC,
      roomTemperatureSource: data.roomTemperatureSource.present
          ? data.roomTemperatureSource.value
          : this.roomTemperatureSource,
      outsideTemperatureC: data.outsideTemperatureC.present
          ? data.outsideTemperatureC.value
          : this.outsideTemperatureC,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingRow(')
          ..write('id: $id, ')
          ..write('roomTemperatureC: $roomTemperatureC, ')
          ..write('roomTemperatureSource: $roomTemperatureSource, ')
          ..write('outsideTemperatureC: $outsideTemperatureC, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roomTemperatureC,
    roomTemperatureSource,
    outsideTemperatureC,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingRow &&
          other.id == this.id &&
          other.roomTemperatureC == this.roomTemperatureC &&
          other.roomTemperatureSource == this.roomTemperatureSource &&
          other.outsideTemperatureC == this.outsideTemperatureC &&
          other.recordedAt == this.recordedAt);
}

class ReadingsCompanion extends UpdateCompanion<ReadingRow> {
  final Value<int> id;
  final Value<double> roomTemperatureC;
  final Value<String> roomTemperatureSource;
  final Value<double> outsideTemperatureC;
  final Value<DateTime> recordedAt;
  const ReadingsCompanion({
    this.id = const Value.absent(),
    this.roomTemperatureC = const Value.absent(),
    this.roomTemperatureSource = const Value.absent(),
    this.outsideTemperatureC = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  ReadingsCompanion.insert({
    this.id = const Value.absent(),
    required double roomTemperatureC,
    required String roomTemperatureSource,
    required double outsideTemperatureC,
    required DateTime recordedAt,
  }) : roomTemperatureC = Value(roomTemperatureC),
       roomTemperatureSource = Value(roomTemperatureSource),
       outsideTemperatureC = Value(outsideTemperatureC),
       recordedAt = Value(recordedAt);
  static Insertable<ReadingRow> custom({
    Expression<int>? id,
    Expression<double>? roomTemperatureC,
    Expression<String>? roomTemperatureSource,
    Expression<double>? outsideTemperatureC,
    Expression<DateTime>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomTemperatureC != null) 'room_temperature_c': roomTemperatureC,
      if (roomTemperatureSource != null)
        'room_temperature_source': roomTemperatureSource,
      if (outsideTemperatureC != null)
        'outside_temperature_c': outsideTemperatureC,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  ReadingsCompanion copyWith({
    Value<int>? id,
    Value<double>? roomTemperatureC,
    Value<String>? roomTemperatureSource,
    Value<double>? outsideTemperatureC,
    Value<DateTime>? recordedAt,
  }) {
    return ReadingsCompanion(
      id: id ?? this.id,
      roomTemperatureC: roomTemperatureC ?? this.roomTemperatureC,
      roomTemperatureSource:
          roomTemperatureSource ?? this.roomTemperatureSource,
      outsideTemperatureC: outsideTemperatureC ?? this.outsideTemperatureC,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roomTemperatureC.present) {
      map['room_temperature_c'] = Variable<double>(roomTemperatureC.value);
    }
    if (roomTemperatureSource.present) {
      map['room_temperature_source'] = Variable<String>(
        roomTemperatureSource.value,
      );
    }
    if (outsideTemperatureC.present) {
      map['outside_temperature_c'] = Variable<double>(
        outsideTemperatureC.value,
      );
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingsCompanion(')
          ..write('id: $id, ')
          ..write('roomTemperatureC: $roomTemperatureC, ')
          ..write('roomTemperatureSource: $roomTemperatureSource, ')
          ..write('outsideTemperatureC: $outsideTemperatureC, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $DailyAveragesTable extends DailyAverages
    with TableInfo<$DailyAveragesTable, DailyAverageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyAveragesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sumRoomTempCMeta = const VerificationMeta(
    'sumRoomTempC',
  );
  @override
  late final GeneratedColumn<double> sumRoomTempC = GeneratedColumn<double>(
    'sum_room_temp_c',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sumOutsideTempCMeta = const VerificationMeta(
    'sumOutsideTempC',
  );
  @override
  late final GeneratedColumn<double> sumOutsideTempC = GeneratedColumn<double>(
    'sum_outside_temp_c',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sampleCountMeta = const VerificationMeta(
    'sampleCount',
  );
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
    'sample_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    day,
    sumRoomTempC,
    sumOutsideTempC,
    sampleCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_averages';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyAverageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('sum_room_temp_c')) {
      context.handle(
        _sumRoomTempCMeta,
        sumRoomTempC.isAcceptableOrUnknown(
          data['sum_room_temp_c']!,
          _sumRoomTempCMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sumRoomTempCMeta);
    }
    if (data.containsKey('sum_outside_temp_c')) {
      context.handle(
        _sumOutsideTempCMeta,
        sumOutsideTempC.isAcceptableOrUnknown(
          data['sum_outside_temp_c']!,
          _sumOutsideTempCMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sumOutsideTempCMeta);
    }
    if (data.containsKey('sample_count')) {
      context.handle(
        _sampleCountMeta,
        sampleCount.isAcceptableOrUnknown(
          data['sample_count']!,
          _sampleCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sampleCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DailyAverageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyAverageRow(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      sumRoomTempC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sum_room_temp_c'],
      )!,
      sumOutsideTempC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sum_outside_temp_c'],
      )!,
      sampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count'],
      )!,
    );
  }

  @override
  $DailyAveragesTable createAlias(String alias) {
    return $DailyAveragesTable(attachedDatabase, alias);
  }
}

class DailyAverageRow extends DataClass implements Insertable<DailyAverageRow> {
  /// The calendar day this row covers, normalized to midnight UTC.
  final DateTime day;

  /// The sum of every room temperature sample recorded on [day], in Celsius.
  final double sumRoomTempC;

  /// The sum of every outside temperature sample recorded on [day], in
  /// Celsius.
  final double sumOutsideTempC;

  /// The number of samples folded into the sums on [day].
  final int sampleCount;
  const DailyAverageRow({
    required this.day,
    required this.sumRoomTempC,
    required this.sumOutsideTempC,
    required this.sampleCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<DateTime>(day);
    map['sum_room_temp_c'] = Variable<double>(sumRoomTempC);
    map['sum_outside_temp_c'] = Variable<double>(sumOutsideTempC);
    map['sample_count'] = Variable<int>(sampleCount);
    return map;
  }

  DailyAveragesCompanion toCompanion(bool nullToAbsent) {
    return DailyAveragesCompanion(
      day: Value(day),
      sumRoomTempC: Value(sumRoomTempC),
      sumOutsideTempC: Value(sumOutsideTempC),
      sampleCount: Value(sampleCount),
    );
  }

  factory DailyAverageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyAverageRow(
      day: serializer.fromJson<DateTime>(json['day']),
      sumRoomTempC: serializer.fromJson<double>(json['sumRoomTempC']),
      sumOutsideTempC: serializer.fromJson<double>(json['sumOutsideTempC']),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<DateTime>(day),
      'sumRoomTempC': serializer.toJson<double>(sumRoomTempC),
      'sumOutsideTempC': serializer.toJson<double>(sumOutsideTempC),
      'sampleCount': serializer.toJson<int>(sampleCount),
    };
  }

  DailyAverageRow copyWith({
    DateTime? day,
    double? sumRoomTempC,
    double? sumOutsideTempC,
    int? sampleCount,
  }) => DailyAverageRow(
    day: day ?? this.day,
    sumRoomTempC: sumRoomTempC ?? this.sumRoomTempC,
    sumOutsideTempC: sumOutsideTempC ?? this.sumOutsideTempC,
    sampleCount: sampleCount ?? this.sampleCount,
  );
  DailyAverageRow copyWithCompanion(DailyAveragesCompanion data) {
    return DailyAverageRow(
      day: data.day.present ? data.day.value : this.day,
      sumRoomTempC: data.sumRoomTempC.present
          ? data.sumRoomTempC.value
          : this.sumRoomTempC,
      sumOutsideTempC: data.sumOutsideTempC.present
          ? data.sumOutsideTempC.value
          : this.sumOutsideTempC,
      sampleCount: data.sampleCount.present
          ? data.sampleCount.value
          : this.sampleCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyAverageRow(')
          ..write('day: $day, ')
          ..write('sumRoomTempC: $sumRoomTempC, ')
          ..write('sumOutsideTempC: $sumOutsideTempC, ')
          ..write('sampleCount: $sampleCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(day, sumRoomTempC, sumOutsideTempC, sampleCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyAverageRow &&
          other.day == this.day &&
          other.sumRoomTempC == this.sumRoomTempC &&
          other.sumOutsideTempC == this.sumOutsideTempC &&
          other.sampleCount == this.sampleCount);
}

class DailyAveragesCompanion extends UpdateCompanion<DailyAverageRow> {
  final Value<DateTime> day;
  final Value<double> sumRoomTempC;
  final Value<double> sumOutsideTempC;
  final Value<int> sampleCount;
  final Value<int> rowid;
  const DailyAveragesCompanion({
    this.day = const Value.absent(),
    this.sumRoomTempC = const Value.absent(),
    this.sumOutsideTempC = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyAveragesCompanion.insert({
    required DateTime day,
    required double sumRoomTempC,
    required double sumOutsideTempC,
    required int sampleCount,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       sumRoomTempC = Value(sumRoomTempC),
       sumOutsideTempC = Value(sumOutsideTempC),
       sampleCount = Value(sampleCount);
  static Insertable<DailyAverageRow> custom({
    Expression<DateTime>? day,
    Expression<double>? sumRoomTempC,
    Expression<double>? sumOutsideTempC,
    Expression<int>? sampleCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (sumRoomTempC != null) 'sum_room_temp_c': sumRoomTempC,
      if (sumOutsideTempC != null) 'sum_outside_temp_c': sumOutsideTempC,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyAveragesCompanion copyWith({
    Value<DateTime>? day,
    Value<double>? sumRoomTempC,
    Value<double>? sumOutsideTempC,
    Value<int>? sampleCount,
    Value<int>? rowid,
  }) {
    return DailyAveragesCompanion(
      day: day ?? this.day,
      sumRoomTempC: sumRoomTempC ?? this.sumRoomTempC,
      sumOutsideTempC: sumOutsideTempC ?? this.sumOutsideTempC,
      sampleCount: sampleCount ?? this.sampleCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (sumRoomTempC.present) {
      map['sum_room_temp_c'] = Variable<double>(sumRoomTempC.value);
    }
    if (sumOutsideTempC.present) {
      map['sum_outside_temp_c'] = Variable<double>(sumOutsideTempC.value);
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyAveragesCompanion(')
          ..write('day: $day, ')
          ..write('sumRoomTempC: $sumRoomTempC, ')
          ..write('sumOutsideTempC: $sumOutsideTempC, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsRowsTable extends SettingsRows
    with TableInfo<$SettingsRowsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsRowsTable createAlias(String alias) {
    return $SettingsRowsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  /// The setting's key.
  final String key;

  /// The setting's value, encoded as text by the writing feature.
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return SettingsRowsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsRowsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsRowsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsRowsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsRowsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlacesTable extends Places with TableInfo<$PlacesTable, PlaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    latitude,
    longitude,
    name,
    address,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'places';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlacesTable createAlias(String alias) {
    return $PlacesTable(attachedDatabase, alias);
  }
}

class PlaceRow extends DataClass implements Insertable<PlaceRow> {
  /// Surrogate primary key.
  final int id;

  /// Visit-cluster latitude, in degrees.
  final double latitude;

  /// Visit-cluster longitude, in degrees.
  final double longitude;

  /// Cached human-readable name, e.g. `Nasr City`.
  final String name;

  /// Optional longer address from reverse geocoding.
  final String? address;

  /// When this place cluster was first created.
  final DateTime createdAt;
  const PlaceRow({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
    this.address,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlacesCompanion toCompanion(bool nullToAbsent) {
    return PlacesCompanion(
      id: Value(id),
      latitude: Value(latitude),
      longitude: Value(longitude),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      createdAt: Value(createdAt),
    );
  }

  factory PlaceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaceRow(
      id: serializer.fromJson<int>(json['id']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlaceRow copyWith({
    int? id,
    double? latitude,
    double? longitude,
    String? name,
    Value<String?> address = const Value.absent(),
    DateTime? createdAt,
  }) => PlaceRow(
    id: id ?? this.id,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    createdAt: createdAt ?? this.createdAt,
  );
  PlaceRow copyWithCompanion(PlacesCompanion data) {
    return PlaceRow(
      id: data.id.present ? data.id.value : this.id,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaceRow(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, latitude, longitude, name, address, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaceRow &&
          other.id == this.id &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.name == this.name &&
          other.address == this.address &&
          other.createdAt == this.createdAt);
}

class PlacesCompanion extends UpdateCompanion<PlaceRow> {
  final Value<int> id;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> name;
  final Value<String?> address;
  final Value<DateTime> createdAt;
  const PlacesCompanion({
    this.id = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlacesCompanion.insert({
    this.id = const Value.absent(),
    required double latitude,
    required double longitude,
    required String name,
    this.address = const Value.absent(),
    required DateTime createdAt,
  }) : latitude = Value(latitude),
       longitude = Value(longitude),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<PlaceRow> custom({
    Expression<int>? id,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? name,
    Expression<String>? address,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlacesCompanion copyWith({
    Value<int>? id,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? name,
    Value<String?>? address,
    Value<DateTime>? createdAt,
  }) {
    return PlacesCompanion(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacesCompanion(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlaceVisitsTable extends PlaceVisits
    with TableInfo<$PlaceVisitsTable, PlaceVisitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaceVisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _placeIdMeta = const VerificationMeta(
    'placeId',
  );
  @override
  late final GeneratedColumn<int> placeId = GeneratedColumn<int>(
    'place_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES places (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sumIndoorCMeta = const VerificationMeta(
    'sumIndoorC',
  );
  @override
  late final GeneratedColumn<double> sumIndoorC = GeneratedColumn<double>(
    'sum_indoor_c',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minIndoorCMeta = const VerificationMeta(
    'minIndoorC',
  );
  @override
  late final GeneratedColumn<double> minIndoorC = GeneratedColumn<double>(
    'min_indoor_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxIndoorCMeta = const VerificationMeta(
    'maxIndoorC',
  );
  @override
  late final GeneratedColumn<double> maxIndoorC = GeneratedColumn<double>(
    'max_indoor_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sampleCountMeta = const VerificationMeta(
    'sampleCount',
  );
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
    'sample_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    placeId,
    latitude,
    longitude,
    startedAt,
    lastSeenAt,
    endedAt,
    durationSeconds,
    sumIndoorC,
    minIndoorC,
    maxIndoorC,
    sampleCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'place_visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaceVisitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('place_id')) {
      context.handle(
        _placeIdMeta,
        placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('sum_indoor_c')) {
      context.handle(
        _sumIndoorCMeta,
        sumIndoorC.isAcceptableOrUnknown(
          data['sum_indoor_c']!,
          _sumIndoorCMeta,
        ),
      );
    }
    if (data.containsKey('min_indoor_c')) {
      context.handle(
        _minIndoorCMeta,
        minIndoorC.isAcceptableOrUnknown(
          data['min_indoor_c']!,
          _minIndoorCMeta,
        ),
      );
    }
    if (data.containsKey('max_indoor_c')) {
      context.handle(
        _maxIndoorCMeta,
        maxIndoorC.isAcceptableOrUnknown(
          data['max_indoor_c']!,
          _maxIndoorCMeta,
        ),
      );
    }
    if (data.containsKey('sample_count')) {
      context.handle(
        _sampleCountMeta,
        sampleCount.isAcceptableOrUnknown(
          data['sample_count']!,
          _sampleCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaceVisitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaceVisitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      placeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}place_id'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      sumIndoorC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sum_indoor_c'],
      )!,
      minIndoorC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_indoor_c'],
      ),
      maxIndoorC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_indoor_c'],
      ),
      sampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count'],
      )!,
    );
  }

  @override
  $PlaceVisitsTable createAlias(String alias) {
    return $PlaceVisitsTable(attachedDatabase, alias);
  }
}

class PlaceVisitRow extends DataClass implements Insertable<PlaceVisitRow> {
  /// Surrogate primary key.
  final int id;

  /// The place this session belongs to. Null while the visit is still open
  /// and has not yet been grouped into a cluster.
  final int? placeId;

  /// Session latitude (first sample).
  final double latitude;

  /// Session longitude (first sample).
  final double longitude;

  /// When the user arrived (first sample of this dwell).
  final DateTime startedAt;

  /// Most recent sample still inside the grouping radius.
  final DateTime lastSeenAt;

  /// When the user left. Null while the visit is still open.
  final DateTime? endedAt;

  /// Closed-visit duration in seconds. Zero while open.
  final int durationSeconds;

  /// Running sum of valid indoor °C samples.
  final double sumIndoorC;

  /// Lowest valid indoor °C, or null before the first sample.
  final double? minIndoorC;

  /// Highest valid indoor °C, or null before the first sample.
  final double? maxIndoorC;

  /// Number of valid indoor samples folded into [sumIndoorC].
  final int sampleCount;
  const PlaceVisitRow({
    required this.id,
    this.placeId,
    required this.latitude,
    required this.longitude,
    required this.startedAt,
    required this.lastSeenAt,
    this.endedAt,
    required this.durationSeconds,
    required this.sumIndoorC,
    this.minIndoorC,
    this.maxIndoorC,
    required this.sampleCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || placeId != null) {
      map['place_id'] = Variable<int>(placeId);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['sum_indoor_c'] = Variable<double>(sumIndoorC);
    if (!nullToAbsent || minIndoorC != null) {
      map['min_indoor_c'] = Variable<double>(minIndoorC);
    }
    if (!nullToAbsent || maxIndoorC != null) {
      map['max_indoor_c'] = Variable<double>(maxIndoorC);
    }
    map['sample_count'] = Variable<int>(sampleCount);
    return map;
  }

  PlaceVisitsCompanion toCompanion(bool nullToAbsent) {
    return PlaceVisitsCompanion(
      id: Value(id),
      placeId: placeId == null && nullToAbsent
          ? const Value.absent()
          : Value(placeId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      startedAt: Value(startedAt),
      lastSeenAt: Value(lastSeenAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationSeconds: Value(durationSeconds),
      sumIndoorC: Value(sumIndoorC),
      minIndoorC: minIndoorC == null && nullToAbsent
          ? const Value.absent()
          : Value(minIndoorC),
      maxIndoorC: maxIndoorC == null && nullToAbsent
          ? const Value.absent()
          : Value(maxIndoorC),
      sampleCount: Value(sampleCount),
    );
  }

  factory PlaceVisitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaceVisitRow(
      id: serializer.fromJson<int>(json['id']),
      placeId: serializer.fromJson<int?>(json['placeId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      sumIndoorC: serializer.fromJson<double>(json['sumIndoorC']),
      minIndoorC: serializer.fromJson<double?>(json['minIndoorC']),
      maxIndoorC: serializer.fromJson<double?>(json['maxIndoorC']),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'placeId': serializer.toJson<int?>(placeId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'sumIndoorC': serializer.toJson<double>(sumIndoorC),
      'minIndoorC': serializer.toJson<double?>(minIndoorC),
      'maxIndoorC': serializer.toJson<double?>(maxIndoorC),
      'sampleCount': serializer.toJson<int>(sampleCount),
    };
  }

  PlaceVisitRow copyWith({
    int? id,
    Value<int?> placeId = const Value.absent(),
    double? latitude,
    double? longitude,
    DateTime? startedAt,
    DateTime? lastSeenAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? durationSeconds,
    double? sumIndoorC,
    Value<double?> minIndoorC = const Value.absent(),
    Value<double?> maxIndoorC = const Value.absent(),
    int? sampleCount,
  }) => PlaceVisitRow(
    id: id ?? this.id,
    placeId: placeId.present ? placeId.value : this.placeId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    startedAt: startedAt ?? this.startedAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    sumIndoorC: sumIndoorC ?? this.sumIndoorC,
    minIndoorC: minIndoorC.present ? minIndoorC.value : this.minIndoorC,
    maxIndoorC: maxIndoorC.present ? maxIndoorC.value : this.maxIndoorC,
    sampleCount: sampleCount ?? this.sampleCount,
  );
  PlaceVisitRow copyWithCompanion(PlaceVisitsCompanion data) {
    return PlaceVisitRow(
      id: data.id.present ? data.id.value : this.id,
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      sumIndoorC: data.sumIndoorC.present
          ? data.sumIndoorC.value
          : this.sumIndoorC,
      minIndoorC: data.minIndoorC.present
          ? data.minIndoorC.value
          : this.minIndoorC,
      maxIndoorC: data.maxIndoorC.present
          ? data.maxIndoorC.value
          : this.maxIndoorC,
      sampleCount: data.sampleCount.present
          ? data.sampleCount.value
          : this.sampleCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaceVisitRow(')
          ..write('id: $id, ')
          ..write('placeId: $placeId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('sumIndoorC: $sumIndoorC, ')
          ..write('minIndoorC: $minIndoorC, ')
          ..write('maxIndoorC: $maxIndoorC, ')
          ..write('sampleCount: $sampleCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    placeId,
    latitude,
    longitude,
    startedAt,
    lastSeenAt,
    endedAt,
    durationSeconds,
    sumIndoorC,
    minIndoorC,
    maxIndoorC,
    sampleCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaceVisitRow &&
          other.id == this.id &&
          other.placeId == this.placeId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.startedAt == this.startedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.sumIndoorC == this.sumIndoorC &&
          other.minIndoorC == this.minIndoorC &&
          other.maxIndoorC == this.maxIndoorC &&
          other.sampleCount == this.sampleCount);
}

class PlaceVisitsCompanion extends UpdateCompanion<PlaceVisitRow> {
  final Value<int> id;
  final Value<int?> placeId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> startedAt;
  final Value<DateTime> lastSeenAt;
  final Value<DateTime?> endedAt;
  final Value<int> durationSeconds;
  final Value<double> sumIndoorC;
  final Value<double?> minIndoorC;
  final Value<double?> maxIndoorC;
  final Value<int> sampleCount;
  const PlaceVisitsCompanion({
    this.id = const Value.absent(),
    this.placeId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.sumIndoorC = const Value.absent(),
    this.minIndoorC = const Value.absent(),
    this.maxIndoorC = const Value.absent(),
    this.sampleCount = const Value.absent(),
  });
  PlaceVisitsCompanion.insert({
    this.id = const Value.absent(),
    this.placeId = const Value.absent(),
    required double latitude,
    required double longitude,
    required DateTime startedAt,
    required DateTime lastSeenAt,
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.sumIndoorC = const Value.absent(),
    this.minIndoorC = const Value.absent(),
    this.maxIndoorC = const Value.absent(),
    this.sampleCount = const Value.absent(),
  }) : latitude = Value(latitude),
       longitude = Value(longitude),
       startedAt = Value(startedAt),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<PlaceVisitRow> custom({
    Expression<int>? id,
    Expression<int>? placeId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationSeconds,
    Expression<double>? sumIndoorC,
    Expression<double>? minIndoorC,
    Expression<double>? maxIndoorC,
    Expression<int>? sampleCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (placeId != null) 'place_id': placeId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (startedAt != null) 'started_at': startedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (sumIndoorC != null) 'sum_indoor_c': sumIndoorC,
      if (minIndoorC != null) 'min_indoor_c': minIndoorC,
      if (maxIndoorC != null) 'max_indoor_c': maxIndoorC,
      if (sampleCount != null) 'sample_count': sampleCount,
    });
  }

  PlaceVisitsCompanion copyWith({
    Value<int>? id,
    Value<int?>? placeId,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<DateTime>? startedAt,
    Value<DateTime>? lastSeenAt,
    Value<DateTime?>? endedAt,
    Value<int>? durationSeconds,
    Value<double>? sumIndoorC,
    Value<double?>? minIndoorC,
    Value<double?>? maxIndoorC,
    Value<int>? sampleCount,
  }) {
    return PlaceVisitsCompanion(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startedAt: startedAt ?? this.startedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      sumIndoorC: sumIndoorC ?? this.sumIndoorC,
      minIndoorC: minIndoorC ?? this.minIndoorC,
      maxIndoorC: maxIndoorC ?? this.maxIndoorC,
      sampleCount: sampleCount ?? this.sampleCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (placeId.present) {
      map['place_id'] = Variable<int>(placeId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (sumIndoorC.present) {
      map['sum_indoor_c'] = Variable<double>(sumIndoorC.value);
    }
    if (minIndoorC.present) {
      map['min_indoor_c'] = Variable<double>(minIndoorC.value);
    }
    if (maxIndoorC.present) {
      map['max_indoor_c'] = Variable<double>(maxIndoorC.value);
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaceVisitsCompanion(')
          ..write('id: $id, ')
          ..write('placeId: $placeId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('sumIndoorC: $sumIndoorC, ')
          ..write('minIndoorC: $minIndoorC, ')
          ..write('maxIndoorC: $maxIndoorC, ')
          ..write('sampleCount: $sampleCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReadingsTable readings = $ReadingsTable(this);
  late final $DailyAveragesTable dailyAverages = $DailyAveragesTable(this);
  late final $SettingsRowsTable settingsRows = $SettingsRowsTable(this);
  late final $PlacesTable places = $PlacesTable(this);
  late final $PlaceVisitsTable placeVisits = $PlaceVisitsTable(this);
  late final Index readingsRecordedAt = Index(
    'readings_recorded_at',
    'CREATE INDEX readings_recorded_at ON readings (recorded_at)',
  );
  late final Index placeVisitsPlaceId = Index(
    'place_visits_place_id',
    'CREATE INDEX place_visits_place_id ON place_visits (place_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    readings,
    dailyAverages,
    settingsRows,
    places,
    placeVisits,
    readingsRecordedAt,
    placeVisitsPlaceId,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'places',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('place_visits', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ReadingsTableCreateCompanionBuilder =
    ReadingsCompanion Function({
      Value<int> id,
      required double roomTemperatureC,
      required String roomTemperatureSource,
      required double outsideTemperatureC,
      required DateTime recordedAt,
    });
typedef $$ReadingsTableUpdateCompanionBuilder =
    ReadingsCompanion Function({
      Value<int> id,
      Value<double> roomTemperatureC,
      Value<String> roomTemperatureSource,
      Value<double> outsideTemperatureC,
      Value<DateTime> recordedAt,
    });

class $$ReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get roomTemperatureC => $composableBuilder(
    column: $table.roomTemperatureC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomTemperatureSource => $composableBuilder(
    column: $table.roomTemperatureSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get outsideTemperatureC => $composableBuilder(
    column: $table.outsideTemperatureC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get roomTemperatureC => $composableBuilder(
    column: $table.roomTemperatureC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomTemperatureSource => $composableBuilder(
    column: $table.roomTemperatureSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get outsideTemperatureC => $composableBuilder(
    column: $table.outsideTemperatureC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get roomTemperatureC => $composableBuilder(
    column: $table.roomTemperatureC,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roomTemperatureSource => $composableBuilder(
    column: $table.roomTemperatureSource,
    builder: (column) => column,
  );

  GeneratedColumn<double> get outsideTemperatureC => $composableBuilder(
    column: $table.outsideTemperatureC,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$ReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingsTable,
          ReadingRow,
          $$ReadingsTableFilterComposer,
          $$ReadingsTableOrderingComposer,
          $$ReadingsTableAnnotationComposer,
          $$ReadingsTableCreateCompanionBuilder,
          $$ReadingsTableUpdateCompanionBuilder,
          (
            ReadingRow,
            BaseReferences<_$AppDatabase, $ReadingsTable, ReadingRow>,
          ),
          ReadingRow,
          PrefetchHooks Function()
        > {
  $$ReadingsTableTableManager(_$AppDatabase db, $ReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> roomTemperatureC = const Value.absent(),
                Value<String> roomTemperatureSource = const Value.absent(),
                Value<double> outsideTemperatureC = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
              }) => ReadingsCompanion(
                id: id,
                roomTemperatureC: roomTemperatureC,
                roomTemperatureSource: roomTemperatureSource,
                outsideTemperatureC: outsideTemperatureC,
                recordedAt: recordedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double roomTemperatureC,
                required String roomTemperatureSource,
                required double outsideTemperatureC,
                required DateTime recordedAt,
              }) => ReadingsCompanion.insert(
                id: id,
                roomTemperatureC: roomTemperatureC,
                roomTemperatureSource: roomTemperatureSource,
                outsideTemperatureC: outsideTemperatureC,
                recordedAt: recordedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingsTable,
      ReadingRow,
      $$ReadingsTableFilterComposer,
      $$ReadingsTableOrderingComposer,
      $$ReadingsTableAnnotationComposer,
      $$ReadingsTableCreateCompanionBuilder,
      $$ReadingsTableUpdateCompanionBuilder,
      (ReadingRow, BaseReferences<_$AppDatabase, $ReadingsTable, ReadingRow>),
      ReadingRow,
      PrefetchHooks Function()
    >;
typedef $$DailyAveragesTableCreateCompanionBuilder =
    DailyAveragesCompanion Function({
      required DateTime day,
      required double sumRoomTempC,
      required double sumOutsideTempC,
      required int sampleCount,
      Value<int> rowid,
    });
typedef $$DailyAveragesTableUpdateCompanionBuilder =
    DailyAveragesCompanion Function({
      Value<DateTime> day,
      Value<double> sumRoomTempC,
      Value<double> sumOutsideTempC,
      Value<int> sampleCount,
      Value<int> rowid,
    });

class $$DailyAveragesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyAveragesTable> {
  $$DailyAveragesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sumRoomTempC => $composableBuilder(
    column: $table.sumRoomTempC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sumOutsideTempC => $composableBuilder(
    column: $table.sumOutsideTempC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyAveragesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyAveragesTable> {
  $$DailyAveragesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sumRoomTempC => $composableBuilder(
    column: $table.sumRoomTempC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sumOutsideTempC => $composableBuilder(
    column: $table.sumOutsideTempC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyAveragesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyAveragesTable> {
  $$DailyAveragesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<double> get sumRoomTempC => $composableBuilder(
    column: $table.sumRoomTempC,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sumOutsideTempC => $composableBuilder(
    column: $table.sumOutsideTempC,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => column,
  );
}

class $$DailyAveragesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyAveragesTable,
          DailyAverageRow,
          $$DailyAveragesTableFilterComposer,
          $$DailyAveragesTableOrderingComposer,
          $$DailyAveragesTableAnnotationComposer,
          $$DailyAveragesTableCreateCompanionBuilder,
          $$DailyAveragesTableUpdateCompanionBuilder,
          (
            DailyAverageRow,
            BaseReferences<_$AppDatabase, $DailyAveragesTable, DailyAverageRow>,
          ),
          DailyAverageRow,
          PrefetchHooks Function()
        > {
  $$DailyAveragesTableTableManager(_$AppDatabase db, $DailyAveragesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyAveragesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyAveragesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyAveragesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> day = const Value.absent(),
                Value<double> sumRoomTempC = const Value.absent(),
                Value<double> sumOutsideTempC = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyAveragesCompanion(
                day: day,
                sumRoomTempC: sumRoomTempC,
                sumOutsideTempC: sumOutsideTempC,
                sampleCount: sampleCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime day,
                required double sumRoomTempC,
                required double sumOutsideTempC,
                required int sampleCount,
                Value<int> rowid = const Value.absent(),
              }) => DailyAveragesCompanion.insert(
                day: day,
                sumRoomTempC: sumRoomTempC,
                sumOutsideTempC: sumOutsideTempC,
                sampleCount: sampleCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyAveragesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyAveragesTable,
      DailyAverageRow,
      $$DailyAveragesTableFilterComposer,
      $$DailyAveragesTableOrderingComposer,
      $$DailyAveragesTableAnnotationComposer,
      $$DailyAveragesTableCreateCompanionBuilder,
      $$DailyAveragesTableUpdateCompanionBuilder,
      (
        DailyAverageRow,
        BaseReferences<_$AppDatabase, $DailyAveragesTable, DailyAverageRow>,
      ),
      DailyAverageRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsRowsTableCreateCompanionBuilder =
    SettingsRowsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsRowsTableUpdateCompanionBuilder =
    SettingsRowsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsRowsTable,
          SettingRow,
          $$SettingsRowsTableFilterComposer,
          $$SettingsRowsTableOrderingComposer,
          $$SettingsRowsTableAnnotationComposer,
          $$SettingsRowsTableCreateCompanionBuilder,
          $$SettingsRowsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsRowsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsRowsTableTableManager(_$AppDatabase db, $SettingsRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsRowsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsRowsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsRowsTable,
      SettingRow,
      $$SettingsRowsTableFilterComposer,
      $$SettingsRowsTableOrderingComposer,
      $$SettingsRowsTableAnnotationComposer,
      $$SettingsRowsTableCreateCompanionBuilder,
      $$SettingsRowsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $SettingsRowsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$PlacesTableCreateCompanionBuilder =
    PlacesCompanion Function({
      Value<int> id,
      required double latitude,
      required double longitude,
      required String name,
      Value<String?> address,
      required DateTime createdAt,
    });
typedef $$PlacesTableUpdateCompanionBuilder =
    PlacesCompanion Function({
      Value<int> id,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> name,
      Value<String?> address,
      Value<DateTime> createdAt,
    });

final class $$PlacesTableReferences
    extends BaseReferences<_$AppDatabase, $PlacesTable, PlaceRow> {
  $$PlacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaceVisitsTable, List<PlaceVisitRow>>
  _placeVisitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.placeVisits,
    aliasName: 'places__id__place_visits__place_id',
  );

  $$PlaceVisitsTableProcessedTableManager get placeVisitsRefs {
    final manager = $$PlaceVisitsTableTableManager(
      $_db,
      $_db.placeVisits,
    ).filter((f) => f.placeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_placeVisitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlacesTableFilterComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> placeVisitsRefs(
    Expression<bool> Function($$PlaceVisitsTableFilterComposer f) f,
  ) {
    final $$PlaceVisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.placeVisits,
      getReferencedColumn: (t) => t.placeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaceVisitsTableFilterComposer(
            $db: $db,
            $table: $db.placeVisits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlacesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> placeVisitsRefs<T extends Object>(
    Expression<T> Function($$PlaceVisitsTableAnnotationComposer a) f,
  ) {
    final $$PlaceVisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.placeVisits,
      getReferencedColumn: (t) => t.placeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaceVisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.placeVisits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlacesTable,
          PlaceRow,
          $$PlacesTableFilterComposer,
          $$PlacesTableOrderingComposer,
          $$PlacesTableAnnotationComposer,
          $$PlacesTableCreateCompanionBuilder,
          $$PlacesTableUpdateCompanionBuilder,
          (PlaceRow, $$PlacesTableReferences),
          PlaceRow,
          PrefetchHooks Function({bool placeVisitsRefs})
        > {
  $$PlacesTableTableManager(_$AppDatabase db, $PlacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlacesCompanion(
                id: id,
                latitude: latitude,
                longitude: longitude,
                name: name,
                address: address,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double latitude,
                required double longitude,
                required String name,
                Value<String?> address = const Value.absent(),
                required DateTime createdAt,
              }) => PlacesCompanion.insert(
                id: id,
                latitude: latitude,
                longitude: longitude,
                name: name,
                address: address,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlacesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({placeVisitsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (placeVisitsRefs) db.placeVisits],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (placeVisitsRefs)
                    await $_getPrefetchedData<
                      PlaceRow,
                      $PlacesTable,
                      PlaceVisitRow
                    >(
                      currentTable: table,
                      referencedTable: $$PlacesTableReferences
                          ._placeVisitsRefsTable(db),
                      managerFromTypedResult: (p0) => $$PlacesTableReferences(
                        db,
                        table,
                        p0,
                      ).placeVisitsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.placeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlacesTable,
      PlaceRow,
      $$PlacesTableFilterComposer,
      $$PlacesTableOrderingComposer,
      $$PlacesTableAnnotationComposer,
      $$PlacesTableCreateCompanionBuilder,
      $$PlacesTableUpdateCompanionBuilder,
      (PlaceRow, $$PlacesTableReferences),
      PlaceRow,
      PrefetchHooks Function({bool placeVisitsRefs})
    >;
typedef $$PlaceVisitsTableCreateCompanionBuilder =
    PlaceVisitsCompanion Function({
      Value<int> id,
      Value<int?> placeId,
      required double latitude,
      required double longitude,
      required DateTime startedAt,
      required DateTime lastSeenAt,
      Value<DateTime?> endedAt,
      Value<int> durationSeconds,
      Value<double> sumIndoorC,
      Value<double?> minIndoorC,
      Value<double?> maxIndoorC,
      Value<int> sampleCount,
    });
typedef $$PlaceVisitsTableUpdateCompanionBuilder =
    PlaceVisitsCompanion Function({
      Value<int> id,
      Value<int?> placeId,
      Value<double> latitude,
      Value<double> longitude,
      Value<DateTime> startedAt,
      Value<DateTime> lastSeenAt,
      Value<DateTime?> endedAt,
      Value<int> durationSeconds,
      Value<double> sumIndoorC,
      Value<double?> minIndoorC,
      Value<double?> maxIndoorC,
      Value<int> sampleCount,
    });

final class $$PlaceVisitsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaceVisitsTable, PlaceVisitRow> {
  $$PlaceVisitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlacesTable _placeIdTable(_$AppDatabase db) =>
      db.places.createAlias('place_visits__place_id__places__id');

  $$PlacesTableProcessedTableManager? get placeId {
    final $_column = $_itemColumn<int>('place_id');
    if ($_column == null) return null;
    final manager = $$PlacesTableTableManager(
      $_db,
      $_db.places,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_placeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaceVisitsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaceVisitsTable> {
  $$PlaceVisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sumIndoorC => $composableBuilder(
    column: $table.sumIndoorC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minIndoorC => $composableBuilder(
    column: $table.minIndoorC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxIndoorC => $composableBuilder(
    column: $table.maxIndoorC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnFilters(column),
  );

  $$PlacesTableFilterComposer get placeId {
    final $$PlacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableFilterComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaceVisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaceVisitsTable> {
  $$PlaceVisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sumIndoorC => $composableBuilder(
    column: $table.sumIndoorC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minIndoorC => $composableBuilder(
    column: $table.minIndoorC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxIndoorC => $composableBuilder(
    column: $table.maxIndoorC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlacesTableOrderingComposer get placeId {
    final $$PlacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableOrderingComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaceVisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaceVisitsTable> {
  $$PlaceVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sumIndoorC => $composableBuilder(
    column: $table.sumIndoorC,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minIndoorC => $composableBuilder(
    column: $table.minIndoorC,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxIndoorC => $composableBuilder(
    column: $table.maxIndoorC,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => column,
  );

  $$PlacesTableAnnotationComposer get placeId {
    final $$PlacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableAnnotationComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaceVisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaceVisitsTable,
          PlaceVisitRow,
          $$PlaceVisitsTableFilterComposer,
          $$PlaceVisitsTableOrderingComposer,
          $$PlaceVisitsTableAnnotationComposer,
          $$PlaceVisitsTableCreateCompanionBuilder,
          $$PlaceVisitsTableUpdateCompanionBuilder,
          (PlaceVisitRow, $$PlaceVisitsTableReferences),
          PlaceVisitRow,
          PrefetchHooks Function({bool placeId})
        > {
  $$PlaceVisitsTableTableManager(_$AppDatabase db, $PlaceVisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaceVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaceVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaceVisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> placeId = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> sumIndoorC = const Value.absent(),
                Value<double?> minIndoorC = const Value.absent(),
                Value<double?> maxIndoorC = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
              }) => PlaceVisitsCompanion(
                id: id,
                placeId: placeId,
                latitude: latitude,
                longitude: longitude,
                startedAt: startedAt,
                lastSeenAt: lastSeenAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                sumIndoorC: sumIndoorC,
                minIndoorC: minIndoorC,
                maxIndoorC: maxIndoorC,
                sampleCount: sampleCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> placeId = const Value.absent(),
                required double latitude,
                required double longitude,
                required DateTime startedAt,
                required DateTime lastSeenAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> sumIndoorC = const Value.absent(),
                Value<double?> minIndoorC = const Value.absent(),
                Value<double?> maxIndoorC = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
              }) => PlaceVisitsCompanion.insert(
                id: id,
                placeId: placeId,
                latitude: latitude,
                longitude: longitude,
                startedAt: startedAt,
                lastSeenAt: lastSeenAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                sumIndoorC: sumIndoorC,
                minIndoorC: minIndoorC,
                maxIndoorC: maxIndoorC,
                sampleCount: sampleCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaceVisitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({placeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (placeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.placeId,
                                referencedTable: $$PlaceVisitsTableReferences
                                    ._placeIdTable(db),
                                referencedColumn: $$PlaceVisitsTableReferences
                                    ._placeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaceVisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaceVisitsTable,
      PlaceVisitRow,
      $$PlaceVisitsTableFilterComposer,
      $$PlaceVisitsTableOrderingComposer,
      $$PlaceVisitsTableAnnotationComposer,
      $$PlaceVisitsTableCreateCompanionBuilder,
      $$PlaceVisitsTableUpdateCompanionBuilder,
      (PlaceVisitRow, $$PlaceVisitsTableReferences),
      PlaceVisitRow,
      PrefetchHooks Function({bool placeId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReadingsTableTableManager get readings =>
      $$ReadingsTableTableManager(_db, _db.readings);
  $$DailyAveragesTableTableManager get dailyAverages =>
      $$DailyAveragesTableTableManager(_db, _db.dailyAverages);
  $$SettingsRowsTableTableManager get settingsRows =>
      $$SettingsRowsTableTableManager(_db, _db.settingsRows);
  $$PlacesTableTableManager get places =>
      $$PlacesTableTableManager(_db, _db.places);
  $$PlaceVisitsTableTableManager get placeVisits =>
      $$PlaceVisitsTableTableManager(_db, _db.placeVisits);
}
