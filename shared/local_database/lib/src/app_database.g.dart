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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReadingsTable readings = $ReadingsTable(this);
  late final $DailyAveragesTable dailyAverages = $DailyAveragesTable(this);
  late final $SettingsRowsTable settingsRows = $SettingsRowsTable(this);
  late final Index readingsRecordedAt = Index(
    'readings_recorded_at',
    'CREATE INDEX readings_recorded_at ON readings (recorded_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    readings,
    dailyAverages,
    settingsRows,
    readingsRecordedAt,
  ];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReadingsTableTableManager get readings =>
      $$ReadingsTableTableManager(_db, _db.readings);
  $$DailyAveragesTableTableManager get dailyAverages =>
      $$DailyAveragesTableTableManager(_db, _db.dailyAverages);
  $$SettingsRowsTableTableManager get settingsRows =>
      $$SettingsRowsTableTableManager(_db, _db.settingsRows);
}
