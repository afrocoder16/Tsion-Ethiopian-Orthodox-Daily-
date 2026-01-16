// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MetaTable extends Meta with TableInfo<$MetaTable, MetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaData> instance, {
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
  MetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaData(
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
  $MetaTable createAlias(String alias) {
    return $MetaTable(attachedDatabase, alias);
  }
}

class MetaData extends DataClass implements Insertable<MetaData> {
  final String key;
  final String value;
  const MetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(key: Value(key), value: Value(value));
  }

  factory MetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaData(
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

  MetaData copyWith({String? key, String? value}) =>
      MetaData(key: key ?? this.key, value: value ?? this.value);
  MetaData copyWithCompanion(MetaCompanion data) {
    return MetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaData(')
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
      (other is MetaData && other.key == this.key && other.value == this.value);
}

class MetaCompanion extends UpdateCompanion<MetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetaData> custom({
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

  MetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaCompanion(
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
    return (StringBuffer('MetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedItemsTable extends SavedItems
    with TableInfo<$SavedItemsTable, SavedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtIsoMeta = const VerificationMeta(
    'createdAtIso',
  );
  @override
  late final GeneratedColumn<String> createdAtIso = GeneratedColumn<String>(
    'created_at_iso',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, kind, createdAtIso];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('created_at_iso')) {
      context.handle(
        _createdAtIsoMeta,
        createdAtIso.isAcceptableOrUnknown(
          data['created_at_iso']!,
          _createdAtIsoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtIsoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      createdAtIso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_iso'],
      )!,
    );
  }

  @override
  $SavedItemsTable createAlias(String alias) {
    return $SavedItemsTable(attachedDatabase, alias);
  }
}

class SavedItem extends DataClass implements Insertable<SavedItem> {
  final String id;
  final String title;
  final String kind;
  final String createdAtIso;
  const SavedItem({
    required this.id,
    required this.title,
    required this.kind,
    required this.createdAtIso,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['kind'] = Variable<String>(kind);
    map['created_at_iso'] = Variable<String>(createdAtIso);
    return map;
  }

  SavedItemsCompanion toCompanion(bool nullToAbsent) {
    return SavedItemsCompanion(
      id: Value(id),
      title: Value(title),
      kind: Value(kind),
      createdAtIso: Value(createdAtIso),
    );
  }

  factory SavedItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedItem(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      kind: serializer.fromJson<String>(json['kind']),
      createdAtIso: serializer.fromJson<String>(json['createdAtIso']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'kind': serializer.toJson<String>(kind),
      'createdAtIso': serializer.toJson<String>(createdAtIso),
    };
  }

  SavedItem copyWith({
    String? id,
    String? title,
    String? kind,
    String? createdAtIso,
  }) => SavedItem(
    id: id ?? this.id,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    createdAtIso: createdAtIso ?? this.createdAtIso,
  );
  SavedItem copyWithCompanion(SavedItemsCompanion data) {
    return SavedItem(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAtIso: data.createdAtIso.present
          ? data.createdAtIso.value
          : this.createdAtIso,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedItem(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('createdAtIso: $createdAtIso')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, kind, createdAtIso);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedItem &&
          other.id == this.id &&
          other.title == this.title &&
          other.kind == this.kind &&
          other.createdAtIso == this.createdAtIso);
}

class SavedItemsCompanion extends UpdateCompanion<SavedItem> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> kind;
  final Value<String> createdAtIso;
  final Value<int> rowid;
  const SavedItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAtIso = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedItemsCompanion.insert({
    required String id,
    required String title,
    required String kind,
    required String createdAtIso,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       kind = Value(kind),
       createdAtIso = Value(createdAtIso);
  static Insertable<SavedItem> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? kind,
    Expression<String>? createdAtIso,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (kind != null) 'kind': kind,
      if (createdAtIso != null) 'created_at_iso': createdAtIso,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? kind,
    Value<String>? createdAtIso,
    Value<int>? rowid,
  }) {
    return SavedItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (createdAtIso.present) {
      map['created_at_iso'] = Variable<String>(createdAtIso.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedItemsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('createdAtIso: $createdAtIso, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressTable extends ReadingProgress
    with TableInfo<$ReadingProgressTable, ReadingProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastLocationMeta = const VerificationMeta(
    'lastLocation',
  );
  @override
  late final GeneratedColumn<String> lastLocation = GeneratedColumn<String>(
    'last_location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressTextMeta = const VerificationMeta(
    'progressText',
  );
  @override
  late final GeneratedColumn<String> progressText = GeneratedColumn<String>(
    'progress_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtIsoMeta = const VerificationMeta(
    'updatedAtIso',
  );
  @override
  late final GeneratedColumn<String> updatedAtIso = GeneratedColumn<String>(
    'updated_at_iso',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookId,
    lastLocation,
    progressText,
    updatedAtIso,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('last_location')) {
      context.handle(
        _lastLocationMeta,
        lastLocation.isAcceptableOrUnknown(
          data['last_location']!,
          _lastLocationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastLocationMeta);
    }
    if (data.containsKey('progress_text')) {
      context.handle(
        _progressTextMeta,
        progressText.isAcceptableOrUnknown(
          data['progress_text']!,
          _progressTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_progressTextMeta);
    }
    if (data.containsKey('updated_at_iso')) {
      context.handle(
        _updatedAtIsoMeta,
        updatedAtIso.isAcceptableOrUnknown(
          data['updated_at_iso']!,
          _updatedAtIsoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtIsoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  ReadingProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressData(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      lastLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_location'],
      )!,
      progressText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}progress_text'],
      )!,
      updatedAtIso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_iso'],
      )!,
    );
  }

  @override
  $ReadingProgressTable createAlias(String alias) {
    return $ReadingProgressTable(attachedDatabase, alias);
  }
}

class ReadingProgressData extends DataClass
    implements Insertable<ReadingProgressData> {
  final String bookId;
  final String lastLocation;
  final String progressText;
  final String updatedAtIso;
  const ReadingProgressData({
    required this.bookId,
    required this.lastLocation,
    required this.progressText,
    required this.updatedAtIso,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['last_location'] = Variable<String>(lastLocation);
    map['progress_text'] = Variable<String>(progressText);
    map['updated_at_iso'] = Variable<String>(updatedAtIso);
    return map;
  }

  ReadingProgressCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressCompanion(
      bookId: Value(bookId),
      lastLocation: Value(lastLocation),
      progressText: Value(progressText),
      updatedAtIso: Value(updatedAtIso),
    );
  }

  factory ReadingProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressData(
      bookId: serializer.fromJson<String>(json['bookId']),
      lastLocation: serializer.fromJson<String>(json['lastLocation']),
      progressText: serializer.fromJson<String>(json['progressText']),
      updatedAtIso: serializer.fromJson<String>(json['updatedAtIso']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'lastLocation': serializer.toJson<String>(lastLocation),
      'progressText': serializer.toJson<String>(progressText),
      'updatedAtIso': serializer.toJson<String>(updatedAtIso),
    };
  }

  ReadingProgressData copyWith({
    String? bookId,
    String? lastLocation,
    String? progressText,
    String? updatedAtIso,
  }) => ReadingProgressData(
    bookId: bookId ?? this.bookId,
    lastLocation: lastLocation ?? this.lastLocation,
    progressText: progressText ?? this.progressText,
    updatedAtIso: updatedAtIso ?? this.updatedAtIso,
  );
  ReadingProgressData copyWithCompanion(ReadingProgressCompanion data) {
    return ReadingProgressData(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      lastLocation: data.lastLocation.present
          ? data.lastLocation.value
          : this.lastLocation,
      progressText: data.progressText.present
          ? data.progressText.value
          : this.progressText,
      updatedAtIso: data.updatedAtIso.present
          ? data.updatedAtIso.value
          : this.updatedAtIso,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressData(')
          ..write('bookId: $bookId, ')
          ..write('lastLocation: $lastLocation, ')
          ..write('progressText: $progressText, ')
          ..write('updatedAtIso: $updatedAtIso')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(bookId, lastLocation, progressText, updatedAtIso);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressData &&
          other.bookId == this.bookId &&
          other.lastLocation == this.lastLocation &&
          other.progressText == this.progressText &&
          other.updatedAtIso == this.updatedAtIso);
}

class ReadingProgressCompanion extends UpdateCompanion<ReadingProgressData> {
  final Value<String> bookId;
  final Value<String> lastLocation;
  final Value<String> progressText;
  final Value<String> updatedAtIso;
  final Value<int> rowid;
  const ReadingProgressCompanion({
    this.bookId = const Value.absent(),
    this.lastLocation = const Value.absent(),
    this.progressText = const Value.absent(),
    this.updatedAtIso = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressCompanion.insert({
    required String bookId,
    required String lastLocation,
    required String progressText,
    required String updatedAtIso,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       lastLocation = Value(lastLocation),
       progressText = Value(progressText),
       updatedAtIso = Value(updatedAtIso);
  static Insertable<ReadingProgressData> custom({
    Expression<String>? bookId,
    Expression<String>? lastLocation,
    Expression<String>? progressText,
    Expression<String>? updatedAtIso,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (lastLocation != null) 'last_location': lastLocation,
      if (progressText != null) 'progress_text': progressText,
      if (updatedAtIso != null) 'updated_at_iso': updatedAtIso,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressCompanion copyWith({
    Value<String>? bookId,
    Value<String>? lastLocation,
    Value<String>? progressText,
    Value<String>? updatedAtIso,
    Value<int>? rowid,
  }) {
    return ReadingProgressCompanion(
      bookId: bookId ?? this.bookId,
      lastLocation: lastLocation ?? this.lastLocation,
      progressText: progressText ?? this.progressText,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (lastLocation.present) {
      map['last_location'] = Variable<String>(lastLocation.value);
    }
    if (progressText.present) {
      map['progress_text'] = Variable<String>(progressText.value);
    }
    if (updatedAtIso.present) {
      map['updated_at_iso'] = Variable<String>(updatedAtIso.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressCompanion(')
          ..write('bookId: $bookId, ')
          ..write('lastLocation: $lastLocation, ')
          ..write('progressText: $progressText, ')
          ..write('updatedAtIso: $updatedAtIso, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreakTasksTable extends StreakTasks
    with TableInfo<$StreakTasksTable, StreakTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreakTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRequiredMeta = const VerificationMeta(
    'isRequired',
  );
  @override
  late final GeneratedColumn<bool> isRequired = GeneratedColumn<bool>(
    'is_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_required" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [taskId, title, isRequired];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreakTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_required')) {
      context.handle(
        _isRequiredMeta,
        isRequired.isAcceptableOrUnknown(data['is_required']!, _isRequiredMeta),
      );
    } else if (isInserting) {
      context.missing(_isRequiredMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId};
  @override
  StreakTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakTask(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_required'],
      )!,
    );
  }

  @override
  $StreakTasksTable createAlias(String alias) {
    return $StreakTasksTable(attachedDatabase, alias);
  }
}

class StreakTask extends DataClass implements Insertable<StreakTask> {
  final String taskId;
  final String title;
  final bool isRequired;
  const StreakTask({
    required this.taskId,
    required this.title,
    required this.isRequired,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    map['is_required'] = Variable<bool>(isRequired);
    return map;
  }

  StreakTasksCompanion toCompanion(bool nullToAbsent) {
    return StreakTasksCompanion(
      taskId: Value(taskId),
      title: Value(title),
      isRequired: Value(isRequired),
    );
  }

  factory StreakTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakTask(
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      isRequired: serializer.fromJson<bool>(json['isRequired']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'isRequired': serializer.toJson<bool>(isRequired),
    };
  }

  StreakTask copyWith({String? taskId, String? title, bool? isRequired}) =>
      StreakTask(
        taskId: taskId ?? this.taskId,
        title: title ?? this.title,
        isRequired: isRequired ?? this.isRequired,
      );
  StreakTask copyWithCompanion(StreakTasksCompanion data) {
    return StreakTask(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      isRequired: data.isRequired.present
          ? data.isRequired.value
          : this.isRequired,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakTask(')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isRequired: $isRequired')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, title, isRequired);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakTask &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.isRequired == this.isRequired);
}

class StreakTasksCompanion extends UpdateCompanion<StreakTask> {
  final Value<String> taskId;
  final Value<String> title;
  final Value<bool> isRequired;
  final Value<int> rowid;
  const StreakTasksCompanion({
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StreakTasksCompanion.insert({
    required String taskId,
    required String title,
    required bool isRequired,
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       title = Value(title),
       isRequired = Value(isRequired);
  static Insertable<StreakTask> custom({
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<bool>? isRequired,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (isRequired != null) 'is_required': isRequired,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StreakTasksCompanion copyWith({
    Value<String>? taskId,
    Value<String>? title,
    Value<bool>? isRequired,
    Value<int>? rowid,
  }) {
    return StreakTasksCompanion(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isRequired: isRequired ?? this.isRequired,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isRequired.present) {
      map['is_required'] = Variable<bool>(isRequired.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreakTasksCompanion(')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isRequired: $isRequired, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreakEventsTable extends StreakEvents
    with TableInfo<$StreakEventsTable, StreakEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreakEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateYmdMeta = const VerificationMeta(
    'dateYmd',
  );
  @override
  late final GeneratedColumn<String> dateYmd = GeneratedColumn<String>(
    'date_ymd',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtIsoMeta = const VerificationMeta(
    'completedAtIso',
  );
  @override
  late final GeneratedColumn<String> completedAtIso = GeneratedColumn<String>(
    'completed_at_iso',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, dateYmd, taskId, completedAtIso];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreakEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_ymd')) {
      context.handle(
        _dateYmdMeta,
        dateYmd.isAcceptableOrUnknown(data['date_ymd']!, _dateYmdMeta),
      );
    } else if (isInserting) {
      context.missing(_dateYmdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('completed_at_iso')) {
      context.handle(
        _completedAtIsoMeta,
        completedAtIso.isAcceptableOrUnknown(
          data['completed_at_iso']!,
          _completedAtIsoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtIsoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StreakEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dateYmd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_ymd'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      completedAtIso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_at_iso'],
      )!,
    );
  }

  @override
  $StreakEventsTable createAlias(String alias) {
    return $StreakEventsTable(attachedDatabase, alias);
  }
}

class StreakEvent extends DataClass implements Insertable<StreakEvent> {
  final int id;
  final String dateYmd;
  final String taskId;
  final String completedAtIso;
  const StreakEvent({
    required this.id,
    required this.dateYmd,
    required this.taskId,
    required this.completedAtIso,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date_ymd'] = Variable<String>(dateYmd);
    map['task_id'] = Variable<String>(taskId);
    map['completed_at_iso'] = Variable<String>(completedAtIso);
    return map;
  }

  StreakEventsCompanion toCompanion(bool nullToAbsent) {
    return StreakEventsCompanion(
      id: Value(id),
      dateYmd: Value(dateYmd),
      taskId: Value(taskId),
      completedAtIso: Value(completedAtIso),
    );
  }

  factory StreakEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakEvent(
      id: serializer.fromJson<int>(json['id']),
      dateYmd: serializer.fromJson<String>(json['dateYmd']),
      taskId: serializer.fromJson<String>(json['taskId']),
      completedAtIso: serializer.fromJson<String>(json['completedAtIso']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dateYmd': serializer.toJson<String>(dateYmd),
      'taskId': serializer.toJson<String>(taskId),
      'completedAtIso': serializer.toJson<String>(completedAtIso),
    };
  }

  StreakEvent copyWith({
    int? id,
    String? dateYmd,
    String? taskId,
    String? completedAtIso,
  }) => StreakEvent(
    id: id ?? this.id,
    dateYmd: dateYmd ?? this.dateYmd,
    taskId: taskId ?? this.taskId,
    completedAtIso: completedAtIso ?? this.completedAtIso,
  );
  StreakEvent copyWithCompanion(StreakEventsCompanion data) {
    return StreakEvent(
      id: data.id.present ? data.id.value : this.id,
      dateYmd: data.dateYmd.present ? data.dateYmd.value : this.dateYmd,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      completedAtIso: data.completedAtIso.present
          ? data.completedAtIso.value
          : this.completedAtIso,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakEvent(')
          ..write('id: $id, ')
          ..write('dateYmd: $dateYmd, ')
          ..write('taskId: $taskId, ')
          ..write('completedAtIso: $completedAtIso')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dateYmd, taskId, completedAtIso);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakEvent &&
          other.id == this.id &&
          other.dateYmd == this.dateYmd &&
          other.taskId == this.taskId &&
          other.completedAtIso == this.completedAtIso);
}

class StreakEventsCompanion extends UpdateCompanion<StreakEvent> {
  final Value<int> id;
  final Value<String> dateYmd;
  final Value<String> taskId;
  final Value<String> completedAtIso;
  const StreakEventsCompanion({
    this.id = const Value.absent(),
    this.dateYmd = const Value.absent(),
    this.taskId = const Value.absent(),
    this.completedAtIso = const Value.absent(),
  });
  StreakEventsCompanion.insert({
    this.id = const Value.absent(),
    required String dateYmd,
    required String taskId,
    required String completedAtIso,
  }) : dateYmd = Value(dateYmd),
       taskId = Value(taskId),
       completedAtIso = Value(completedAtIso);
  static Insertable<StreakEvent> custom({
    Expression<int>? id,
    Expression<String>? dateYmd,
    Expression<String>? taskId,
    Expression<String>? completedAtIso,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateYmd != null) 'date_ymd': dateYmd,
      if (taskId != null) 'task_id': taskId,
      if (completedAtIso != null) 'completed_at_iso': completedAtIso,
    });
  }

  StreakEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? dateYmd,
    Value<String>? taskId,
    Value<String>? completedAtIso,
  }) {
    return StreakEventsCompanion(
      id: id ?? this.id,
      dateYmd: dateYmd ?? this.dateYmd,
      taskId: taskId ?? this.taskId,
      completedAtIso: completedAtIso ?? this.completedAtIso,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dateYmd.present) {
      map['date_ymd'] = Variable<String>(dateYmd.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (completedAtIso.present) {
      map['completed_at_iso'] = Variable<String>(completedAtIso.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreakEventsCompanion(')
          ..write('id: $id, ')
          ..write('dateYmd: $dateYmd, ')
          ..write('taskId: $taskId, ')
          ..write('completedAtIso: $completedAtIso')
          ..write(')'))
        .toString();
  }
}

class $PrayerScheduleTable extends PrayerSchedule
    with TableInfo<$PrayerScheduleTable, PrayerScheduleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerScheduleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotIdMeta = const VerificationMeta('slotId');
  @override
  late final GeneratedColumn<int> slotId = GeneratedColumn<int>(
    'slot_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeLocalMeta = const VerificationMeta(
    'timeLocal',
  );
  @override
  late final GeneratedColumn<String> timeLocal = GeneratedColumn<String>(
    'time_local',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [slotId, label, timeLocal, isEnabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_schedule';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerScheduleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot_id')) {
      context.handle(
        _slotIdMeta,
        slotId.isAcceptableOrUnknown(data['slot_id']!, _slotIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('time_local')) {
      context.handle(
        _timeLocalMeta,
        timeLocal.isAcceptableOrUnknown(data['time_local']!, _timeLocalMeta),
      );
    } else if (isInserting) {
      context.missing(_timeLocalMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    } else if (isInserting) {
      context.missing(_isEnabledMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slotId};
  @override
  PrayerScheduleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerScheduleData(
      slotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      timeLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_local'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
    );
  }

  @override
  $PrayerScheduleTable createAlias(String alias) {
    return $PrayerScheduleTable(attachedDatabase, alias);
  }
}

class PrayerScheduleData extends DataClass
    implements Insertable<PrayerScheduleData> {
  final int slotId;
  final String label;
  final String timeLocal;
  final bool isEnabled;
  const PrayerScheduleData({
    required this.slotId,
    required this.label,
    required this.timeLocal,
    required this.isEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot_id'] = Variable<int>(slotId);
    map['label'] = Variable<String>(label);
    map['time_local'] = Variable<String>(timeLocal);
    map['is_enabled'] = Variable<bool>(isEnabled);
    return map;
  }

  PrayerScheduleCompanion toCompanion(bool nullToAbsent) {
    return PrayerScheduleCompanion(
      slotId: Value(slotId),
      label: Value(label),
      timeLocal: Value(timeLocal),
      isEnabled: Value(isEnabled),
    );
  }

  factory PrayerScheduleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerScheduleData(
      slotId: serializer.fromJson<int>(json['slotId']),
      label: serializer.fromJson<String>(json['label']),
      timeLocal: serializer.fromJson<String>(json['timeLocal']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slotId': serializer.toJson<int>(slotId),
      'label': serializer.toJson<String>(label),
      'timeLocal': serializer.toJson<String>(timeLocal),
      'isEnabled': serializer.toJson<bool>(isEnabled),
    };
  }

  PrayerScheduleData copyWith({
    int? slotId,
    String? label,
    String? timeLocal,
    bool? isEnabled,
  }) => PrayerScheduleData(
    slotId: slotId ?? this.slotId,
    label: label ?? this.label,
    timeLocal: timeLocal ?? this.timeLocal,
    isEnabled: isEnabled ?? this.isEnabled,
  );
  PrayerScheduleData copyWithCompanion(PrayerScheduleCompanion data) {
    return PrayerScheduleData(
      slotId: data.slotId.present ? data.slotId.value : this.slotId,
      label: data.label.present ? data.label.value : this.label,
      timeLocal: data.timeLocal.present ? data.timeLocal.value : this.timeLocal,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerScheduleData(')
          ..write('slotId: $slotId, ')
          ..write('label: $label, ')
          ..write('timeLocal: $timeLocal, ')
          ..write('isEnabled: $isEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(slotId, label, timeLocal, isEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerScheduleData &&
          other.slotId == this.slotId &&
          other.label == this.label &&
          other.timeLocal == this.timeLocal &&
          other.isEnabled == this.isEnabled);
}

class PrayerScheduleCompanion extends UpdateCompanion<PrayerScheduleData> {
  final Value<int> slotId;
  final Value<String> label;
  final Value<String> timeLocal;
  final Value<bool> isEnabled;
  const PrayerScheduleCompanion({
    this.slotId = const Value.absent(),
    this.label = const Value.absent(),
    this.timeLocal = const Value.absent(),
    this.isEnabled = const Value.absent(),
  });
  PrayerScheduleCompanion.insert({
    this.slotId = const Value.absent(),
    required String label,
    required String timeLocal,
    required bool isEnabled,
  }) : label = Value(label),
       timeLocal = Value(timeLocal),
       isEnabled = Value(isEnabled);
  static Insertable<PrayerScheduleData> custom({
    Expression<int>? slotId,
    Expression<String>? label,
    Expression<String>? timeLocal,
    Expression<bool>? isEnabled,
  }) {
    return RawValuesInsertable({
      if (slotId != null) 'slot_id': slotId,
      if (label != null) 'label': label,
      if (timeLocal != null) 'time_local': timeLocal,
      if (isEnabled != null) 'is_enabled': isEnabled,
    });
  }

  PrayerScheduleCompanion copyWith({
    Value<int>? slotId,
    Value<String>? label,
    Value<String>? timeLocal,
    Value<bool>? isEnabled,
  }) {
    return PrayerScheduleCompanion(
      slotId: slotId ?? this.slotId,
      label: label ?? this.label,
      timeLocal: timeLocal ?? this.timeLocal,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slotId.present) {
      map['slot_id'] = Variable<int>(slotId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (timeLocal.present) {
      map['time_local'] = Variable<String>(timeLocal.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerScheduleCompanion(')
          ..write('slotId: $slotId, ')
          ..write('label: $label, ')
          ..write('timeLocal: $timeLocal, ')
          ..write('isEnabled: $isEnabled')
          ..write(')'))
        .toString();
  }
}

class $PrayerCompletionsTable extends PrayerCompletions
    with TableInfo<$PrayerCompletionsTable, PrayerCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerCompletionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateYmdMeta = const VerificationMeta(
    'dateYmd',
  );
  @override
  late final GeneratedColumn<String> dateYmd = GeneratedColumn<String>(
    'date_ymd',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotIdMeta = const VerificationMeta('slotId');
  @override
  late final GeneratedColumn<int> slotId = GeneratedColumn<int>(
    'slot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtIsoMeta = const VerificationMeta(
    'completedAtIso',
  );
  @override
  late final GeneratedColumn<String> completedAtIso = GeneratedColumn<String>(
    'completed_at_iso',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, dateYmd, slotId, completedAtIso];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_ymd')) {
      context.handle(
        _dateYmdMeta,
        dateYmd.isAcceptableOrUnknown(data['date_ymd']!, _dateYmdMeta),
      );
    } else if (isInserting) {
      context.missing(_dateYmdMeta);
    }
    if (data.containsKey('slot_id')) {
      context.handle(
        _slotIdMeta,
        slotId.isAcceptableOrUnknown(data['slot_id']!, _slotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_slotIdMeta);
    }
    if (data.containsKey('completed_at_iso')) {
      context.handle(
        _completedAtIsoMeta,
        completedAtIso.isAcceptableOrUnknown(
          data['completed_at_iso']!,
          _completedAtIsoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtIsoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrayerCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerCompletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dateYmd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_ymd'],
      )!,
      slotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_id'],
      )!,
      completedAtIso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_at_iso'],
      )!,
    );
  }

  @override
  $PrayerCompletionsTable createAlias(String alias) {
    return $PrayerCompletionsTable(attachedDatabase, alias);
  }
}

class PrayerCompletion extends DataClass
    implements Insertable<PrayerCompletion> {
  final int id;
  final String dateYmd;
  final int slotId;
  final String completedAtIso;
  const PrayerCompletion({
    required this.id,
    required this.dateYmd,
    required this.slotId,
    required this.completedAtIso,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date_ymd'] = Variable<String>(dateYmd);
    map['slot_id'] = Variable<int>(slotId);
    map['completed_at_iso'] = Variable<String>(completedAtIso);
    return map;
  }

  PrayerCompletionsCompanion toCompanion(bool nullToAbsent) {
    return PrayerCompletionsCompanion(
      id: Value(id),
      dateYmd: Value(dateYmd),
      slotId: Value(slotId),
      completedAtIso: Value(completedAtIso),
    );
  }

  factory PrayerCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerCompletion(
      id: serializer.fromJson<int>(json['id']),
      dateYmd: serializer.fromJson<String>(json['dateYmd']),
      slotId: serializer.fromJson<int>(json['slotId']),
      completedAtIso: serializer.fromJson<String>(json['completedAtIso']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dateYmd': serializer.toJson<String>(dateYmd),
      'slotId': serializer.toJson<int>(slotId),
      'completedAtIso': serializer.toJson<String>(completedAtIso),
    };
  }

  PrayerCompletion copyWith({
    int? id,
    String? dateYmd,
    int? slotId,
    String? completedAtIso,
  }) => PrayerCompletion(
    id: id ?? this.id,
    dateYmd: dateYmd ?? this.dateYmd,
    slotId: slotId ?? this.slotId,
    completedAtIso: completedAtIso ?? this.completedAtIso,
  );
  PrayerCompletion copyWithCompanion(PrayerCompletionsCompanion data) {
    return PrayerCompletion(
      id: data.id.present ? data.id.value : this.id,
      dateYmd: data.dateYmd.present ? data.dateYmd.value : this.dateYmd,
      slotId: data.slotId.present ? data.slotId.value : this.slotId,
      completedAtIso: data.completedAtIso.present
          ? data.completedAtIso.value
          : this.completedAtIso,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerCompletion(')
          ..write('id: $id, ')
          ..write('dateYmd: $dateYmd, ')
          ..write('slotId: $slotId, ')
          ..write('completedAtIso: $completedAtIso')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dateYmd, slotId, completedAtIso);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerCompletion &&
          other.id == this.id &&
          other.dateYmd == this.dateYmd &&
          other.slotId == this.slotId &&
          other.completedAtIso == this.completedAtIso);
}

class PrayerCompletionsCompanion extends UpdateCompanion<PrayerCompletion> {
  final Value<int> id;
  final Value<String> dateYmd;
  final Value<int> slotId;
  final Value<String> completedAtIso;
  const PrayerCompletionsCompanion({
    this.id = const Value.absent(),
    this.dateYmd = const Value.absent(),
    this.slotId = const Value.absent(),
    this.completedAtIso = const Value.absent(),
  });
  PrayerCompletionsCompanion.insert({
    this.id = const Value.absent(),
    required String dateYmd,
    required int slotId,
    required String completedAtIso,
  }) : dateYmd = Value(dateYmd),
       slotId = Value(slotId),
       completedAtIso = Value(completedAtIso);
  static Insertable<PrayerCompletion> custom({
    Expression<int>? id,
    Expression<String>? dateYmd,
    Expression<int>? slotId,
    Expression<String>? completedAtIso,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateYmd != null) 'date_ymd': dateYmd,
      if (slotId != null) 'slot_id': slotId,
      if (completedAtIso != null) 'completed_at_iso': completedAtIso,
    });
  }

  PrayerCompletionsCompanion copyWith({
    Value<int>? id,
    Value<String>? dateYmd,
    Value<int>? slotId,
    Value<String>? completedAtIso,
  }) {
    return PrayerCompletionsCompanion(
      id: id ?? this.id,
      dateYmd: dateYmd ?? this.dateYmd,
      slotId: slotId ?? this.slotId,
      completedAtIso: completedAtIso ?? this.completedAtIso,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dateYmd.present) {
      map['date_ymd'] = Variable<String>(dateYmd.value);
    }
    if (slotId.present) {
      map['slot_id'] = Variable<int>(slotId.value);
    }
    if (completedAtIso.present) {
      map['completed_at_iso'] = Variable<String>(completedAtIso.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('dateYmd: $dateYmd, ')
          ..write('slotId: $slotId, ')
          ..write('completedAtIso: $completedAtIso')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MetaTable meta = $MetaTable(this);
  late final $SavedItemsTable savedItems = $SavedItemsTable(this);
  late final $ReadingProgressTable readingProgress = $ReadingProgressTable(
    this,
  );
  late final $StreakTasksTable streakTasks = $StreakTasksTable(this);
  late final $StreakEventsTable streakEvents = $StreakEventsTable(this);
  late final $PrayerScheduleTable prayerSchedule = $PrayerScheduleTable(this);
  late final $PrayerCompletionsTable prayerCompletions =
      $PrayerCompletionsTable(this);
  late final MetaDao metaDao = MetaDao(this as AppDatabase);
  late final SavedItemsDao savedItemsDao = SavedItemsDao(this as AppDatabase);
  late final ReadingProgressDao readingProgressDao = ReadingProgressDao(
    this as AppDatabase,
  );
  late final StreakDao streakDao = StreakDao(this as AppDatabase);
  late final PrayerDao prayerDao = PrayerDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    meta,
    savedItems,
    readingProgress,
    streakTasks,
    streakEvents,
    prayerSchedule,
    prayerCompletions,
  ];
}

typedef $$MetaTableCreateCompanionBuilder =
    MetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$MetaTableUpdateCompanionBuilder =
    MetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$MetaTableFilterComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableFilterComposer({
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

class $$MetaTableOrderingComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableOrderingComposer({
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

class $$MetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableAnnotationComposer({
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

class $$MetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetaTable,
          MetaData,
          $$MetaTableFilterComposer,
          $$MetaTableOrderingComposer,
          $$MetaTableAnnotationComposer,
          $$MetaTableCreateCompanionBuilder,
          $$MetaTableUpdateCompanionBuilder,
          (MetaData, BaseReferences<_$AppDatabase, $MetaTable, MetaData>),
          MetaData,
          PrefetchHooks Function()
        > {
  $$MetaTableTableManager(_$AppDatabase db, $MetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetaTable,
      MetaData,
      $$MetaTableFilterComposer,
      $$MetaTableOrderingComposer,
      $$MetaTableAnnotationComposer,
      $$MetaTableCreateCompanionBuilder,
      $$MetaTableUpdateCompanionBuilder,
      (MetaData, BaseReferences<_$AppDatabase, $MetaTable, MetaData>),
      MetaData,
      PrefetchHooks Function()
    >;
typedef $$SavedItemsTableCreateCompanionBuilder =
    SavedItemsCompanion Function({
      required String id,
      required String title,
      required String kind,
      required String createdAtIso,
      Value<int> rowid,
    });
typedef $$SavedItemsTableUpdateCompanionBuilder =
    SavedItemsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> kind,
      Value<String> createdAtIso,
      Value<int> rowid,
    });

class $$SavedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAtIso => $composableBuilder(
    column: $table.createdAtIso,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAtIso => $composableBuilder(
    column: $table.createdAtIso,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get createdAtIso => $composableBuilder(
    column: $table.createdAtIso,
    builder: (column) => column,
  );
}

class $$SavedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedItemsTable,
          SavedItem,
          $$SavedItemsTableFilterComposer,
          $$SavedItemsTableOrderingComposer,
          $$SavedItemsTableAnnotationComposer,
          $$SavedItemsTableCreateCompanionBuilder,
          $$SavedItemsTableUpdateCompanionBuilder,
          (
            SavedItem,
            BaseReferences<_$AppDatabase, $SavedItemsTable, SavedItem>,
          ),
          SavedItem,
          PrefetchHooks Function()
        > {
  $$SavedItemsTableTableManager(_$AppDatabase db, $SavedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> createdAtIso = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedItemsCompanion(
                id: id,
                title: title,
                kind: kind,
                createdAtIso: createdAtIso,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String kind,
                required String createdAtIso,
                Value<int> rowid = const Value.absent(),
              }) => SavedItemsCompanion.insert(
                id: id,
                title: title,
                kind: kind,
                createdAtIso: createdAtIso,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedItemsTable,
      SavedItem,
      $$SavedItemsTableFilterComposer,
      $$SavedItemsTableOrderingComposer,
      $$SavedItemsTableAnnotationComposer,
      $$SavedItemsTableCreateCompanionBuilder,
      $$SavedItemsTableUpdateCompanionBuilder,
      (SavedItem, BaseReferences<_$AppDatabase, $SavedItemsTable, SavedItem>),
      SavedItem,
      PrefetchHooks Function()
    >;
typedef $$ReadingProgressTableCreateCompanionBuilder =
    ReadingProgressCompanion Function({
      required String bookId,
      required String lastLocation,
      required String progressText,
      required String updatedAtIso,
      Value<int> rowid,
    });
typedef $$ReadingProgressTableUpdateCompanionBuilder =
    ReadingProgressCompanion Function({
      Value<String> bookId,
      Value<String> lastLocation,
      Value<String> progressText,
      Value<String> updatedAtIso,
      Value<int> rowid,
    });

class $$ReadingProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastLocation => $composableBuilder(
    column: $table.lastLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get progressText => $composableBuilder(
    column: $table.progressText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtIso => $composableBuilder(
    column: $table.updatedAtIso,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastLocation => $composableBuilder(
    column: $table.lastLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get progressText => $composableBuilder(
    column: $table.progressText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtIso => $composableBuilder(
    column: $table.updatedAtIso,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get lastLocation => $composableBuilder(
    column: $table.lastLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get progressText => $composableBuilder(
    column: $table.progressText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtIso => $composableBuilder(
    column: $table.updatedAtIso,
    builder: (column) => column,
  );
}

class $$ReadingProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingProgressTable,
          ReadingProgressData,
          $$ReadingProgressTableFilterComposer,
          $$ReadingProgressTableOrderingComposer,
          $$ReadingProgressTableAnnotationComposer,
          $$ReadingProgressTableCreateCompanionBuilder,
          $$ReadingProgressTableUpdateCompanionBuilder,
          (
            ReadingProgressData,
            BaseReferences<
              _$AppDatabase,
              $ReadingProgressTable,
              ReadingProgressData
            >,
          ),
          ReadingProgressData,
          PrefetchHooks Function()
        > {
  $$ReadingProgressTableTableManager(
    _$AppDatabase db,
    $ReadingProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String> lastLocation = const Value.absent(),
                Value<String> progressText = const Value.absent(),
                Value<String> updatedAtIso = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressCompanion(
                bookId: bookId,
                lastLocation: lastLocation,
                progressText: progressText,
                updatedAtIso: updatedAtIso,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required String lastLocation,
                required String progressText,
                required String updatedAtIso,
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressCompanion.insert(
                bookId: bookId,
                lastLocation: lastLocation,
                progressText: progressText,
                updatedAtIso: updatedAtIso,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingProgressTable,
      ReadingProgressData,
      $$ReadingProgressTableFilterComposer,
      $$ReadingProgressTableOrderingComposer,
      $$ReadingProgressTableAnnotationComposer,
      $$ReadingProgressTableCreateCompanionBuilder,
      $$ReadingProgressTableUpdateCompanionBuilder,
      (
        ReadingProgressData,
        BaseReferences<
          _$AppDatabase,
          $ReadingProgressTable,
          ReadingProgressData
        >,
      ),
      ReadingProgressData,
      PrefetchHooks Function()
    >;
typedef $$StreakTasksTableCreateCompanionBuilder =
    StreakTasksCompanion Function({
      required String taskId,
      required String title,
      required bool isRequired,
      Value<int> rowid,
    });
typedef $$StreakTasksTableUpdateCompanionBuilder =
    StreakTasksCompanion Function({
      Value<String> taskId,
      Value<String> title,
      Value<bool> isRequired,
      Value<int> rowid,
    });

class $$StreakTasksTableFilterComposer
    extends Composer<_$AppDatabase, $StreakTasksTable> {
  $$StreakTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreakTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $StreakTasksTable> {
  $$StreakTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreakTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreakTasksTable> {
  $$StreakTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => column,
  );
}

class $$StreakTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreakTasksTable,
          StreakTask,
          $$StreakTasksTableFilterComposer,
          $$StreakTasksTableOrderingComposer,
          $$StreakTasksTableAnnotationComposer,
          $$StreakTasksTableCreateCompanionBuilder,
          $$StreakTasksTableUpdateCompanionBuilder,
          (
            StreakTask,
            BaseReferences<_$AppDatabase, $StreakTasksTable, StreakTask>,
          ),
          StreakTask,
          PrefetchHooks Function()
        > {
  $$StreakTasksTableTableManager(_$AppDatabase db, $StreakTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreakTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreakTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreakTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isRequired = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StreakTasksCompanion(
                taskId: taskId,
                title: title,
                isRequired: isRequired,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String taskId,
                required String title,
                required bool isRequired,
                Value<int> rowid = const Value.absent(),
              }) => StreakTasksCompanion.insert(
                taskId: taskId,
                title: title,
                isRequired: isRequired,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreakTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreakTasksTable,
      StreakTask,
      $$StreakTasksTableFilterComposer,
      $$StreakTasksTableOrderingComposer,
      $$StreakTasksTableAnnotationComposer,
      $$StreakTasksTableCreateCompanionBuilder,
      $$StreakTasksTableUpdateCompanionBuilder,
      (
        StreakTask,
        BaseReferences<_$AppDatabase, $StreakTasksTable, StreakTask>,
      ),
      StreakTask,
      PrefetchHooks Function()
    >;
typedef $$StreakEventsTableCreateCompanionBuilder =
    StreakEventsCompanion Function({
      Value<int> id,
      required String dateYmd,
      required String taskId,
      required String completedAtIso,
    });
typedef $$StreakEventsTableUpdateCompanionBuilder =
    StreakEventsCompanion Function({
      Value<int> id,
      Value<String> dateYmd,
      Value<String> taskId,
      Value<String> completedAtIso,
    });

class $$StreakEventsTableFilterComposer
    extends Composer<_$AppDatabase, $StreakEventsTable> {
  $$StreakEventsTableFilterComposer({
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

  ColumnFilters<String> get dateYmd => $composableBuilder(
    column: $table.dateYmd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedAtIso => $composableBuilder(
    column: $table.completedAtIso,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreakEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $StreakEventsTable> {
  $$StreakEventsTableOrderingComposer({
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

  ColumnOrderings<String> get dateYmd => $composableBuilder(
    column: $table.dateYmd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedAtIso => $composableBuilder(
    column: $table.completedAtIso,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreakEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreakEventsTable> {
  $$StreakEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateYmd =>
      $composableBuilder(column: $table.dateYmd, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get completedAtIso => $composableBuilder(
    column: $table.completedAtIso,
    builder: (column) => column,
  );
}

class $$StreakEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreakEventsTable,
          StreakEvent,
          $$StreakEventsTableFilterComposer,
          $$StreakEventsTableOrderingComposer,
          $$StreakEventsTableAnnotationComposer,
          $$StreakEventsTableCreateCompanionBuilder,
          $$StreakEventsTableUpdateCompanionBuilder,
          (
            StreakEvent,
            BaseReferences<_$AppDatabase, $StreakEventsTable, StreakEvent>,
          ),
          StreakEvent,
          PrefetchHooks Function()
        > {
  $$StreakEventsTableTableManager(_$AppDatabase db, $StreakEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreakEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreakEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreakEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dateYmd = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> completedAtIso = const Value.absent(),
              }) => StreakEventsCompanion(
                id: id,
                dateYmd: dateYmd,
                taskId: taskId,
                completedAtIso: completedAtIso,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dateYmd,
                required String taskId,
                required String completedAtIso,
              }) => StreakEventsCompanion.insert(
                id: id,
                dateYmd: dateYmd,
                taskId: taskId,
                completedAtIso: completedAtIso,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreakEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreakEventsTable,
      StreakEvent,
      $$StreakEventsTableFilterComposer,
      $$StreakEventsTableOrderingComposer,
      $$StreakEventsTableAnnotationComposer,
      $$StreakEventsTableCreateCompanionBuilder,
      $$StreakEventsTableUpdateCompanionBuilder,
      (
        StreakEvent,
        BaseReferences<_$AppDatabase, $StreakEventsTable, StreakEvent>,
      ),
      StreakEvent,
      PrefetchHooks Function()
    >;
typedef $$PrayerScheduleTableCreateCompanionBuilder =
    PrayerScheduleCompanion Function({
      Value<int> slotId,
      required String label,
      required String timeLocal,
      required bool isEnabled,
    });
typedef $$PrayerScheduleTableUpdateCompanionBuilder =
    PrayerScheduleCompanion Function({
      Value<int> slotId,
      Value<String> label,
      Value<String> timeLocal,
      Value<bool> isEnabled,
    });

class $$PrayerScheduleTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerScheduleTable> {
  $$PrayerScheduleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeLocal => $composableBuilder(
    column: $table.timeLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrayerScheduleTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerScheduleTable> {
  $$PrayerScheduleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeLocal => $composableBuilder(
    column: $table.timeLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayerScheduleTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerScheduleTable> {
  $$PrayerScheduleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slotId =>
      $composableBuilder(column: $table.slotId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get timeLocal =>
      $composableBuilder(column: $table.timeLocal, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);
}

class $$PrayerScheduleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerScheduleTable,
          PrayerScheduleData,
          $$PrayerScheduleTableFilterComposer,
          $$PrayerScheduleTableOrderingComposer,
          $$PrayerScheduleTableAnnotationComposer,
          $$PrayerScheduleTableCreateCompanionBuilder,
          $$PrayerScheduleTableUpdateCompanionBuilder,
          (
            PrayerScheduleData,
            BaseReferences<
              _$AppDatabase,
              $PrayerScheduleTable,
              PrayerScheduleData
            >,
          ),
          PrayerScheduleData,
          PrefetchHooks Function()
        > {
  $$PrayerScheduleTableTableManager(
    _$AppDatabase db,
    $PrayerScheduleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerScheduleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerScheduleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerScheduleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> slotId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> timeLocal = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
              }) => PrayerScheduleCompanion(
                slotId: slotId,
                label: label,
                timeLocal: timeLocal,
                isEnabled: isEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> slotId = const Value.absent(),
                required String label,
                required String timeLocal,
                required bool isEnabled,
              }) => PrayerScheduleCompanion.insert(
                slotId: slotId,
                label: label,
                timeLocal: timeLocal,
                isEnabled: isEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrayerScheduleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerScheduleTable,
      PrayerScheduleData,
      $$PrayerScheduleTableFilterComposer,
      $$PrayerScheduleTableOrderingComposer,
      $$PrayerScheduleTableAnnotationComposer,
      $$PrayerScheduleTableCreateCompanionBuilder,
      $$PrayerScheduleTableUpdateCompanionBuilder,
      (
        PrayerScheduleData,
        BaseReferences<_$AppDatabase, $PrayerScheduleTable, PrayerScheduleData>,
      ),
      PrayerScheduleData,
      PrefetchHooks Function()
    >;
typedef $$PrayerCompletionsTableCreateCompanionBuilder =
    PrayerCompletionsCompanion Function({
      Value<int> id,
      required String dateYmd,
      required int slotId,
      required String completedAtIso,
    });
typedef $$PrayerCompletionsTableUpdateCompanionBuilder =
    PrayerCompletionsCompanion Function({
      Value<int> id,
      Value<String> dateYmd,
      Value<int> slotId,
      Value<String> completedAtIso,
    });

class $$PrayerCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerCompletionsTable> {
  $$PrayerCompletionsTableFilterComposer({
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

  ColumnFilters<String> get dateYmd => $composableBuilder(
    column: $table.dateYmd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedAtIso => $composableBuilder(
    column: $table.completedAtIso,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrayerCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerCompletionsTable> {
  $$PrayerCompletionsTableOrderingComposer({
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

  ColumnOrderings<String> get dateYmd => $composableBuilder(
    column: $table.dateYmd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedAtIso => $composableBuilder(
    column: $table.completedAtIso,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayerCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerCompletionsTable> {
  $$PrayerCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateYmd =>
      $composableBuilder(column: $table.dateYmd, builder: (column) => column);

  GeneratedColumn<int> get slotId =>
      $composableBuilder(column: $table.slotId, builder: (column) => column);

  GeneratedColumn<String> get completedAtIso => $composableBuilder(
    column: $table.completedAtIso,
    builder: (column) => column,
  );
}

class $$PrayerCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerCompletionsTable,
          PrayerCompletion,
          $$PrayerCompletionsTableFilterComposer,
          $$PrayerCompletionsTableOrderingComposer,
          $$PrayerCompletionsTableAnnotationComposer,
          $$PrayerCompletionsTableCreateCompanionBuilder,
          $$PrayerCompletionsTableUpdateCompanionBuilder,
          (
            PrayerCompletion,
            BaseReferences<
              _$AppDatabase,
              $PrayerCompletionsTable,
              PrayerCompletion
            >,
          ),
          PrayerCompletion,
          PrefetchHooks Function()
        > {
  $$PrayerCompletionsTableTableManager(
    _$AppDatabase db,
    $PrayerCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerCompletionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dateYmd = const Value.absent(),
                Value<int> slotId = const Value.absent(),
                Value<String> completedAtIso = const Value.absent(),
              }) => PrayerCompletionsCompanion(
                id: id,
                dateYmd: dateYmd,
                slotId: slotId,
                completedAtIso: completedAtIso,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dateYmd,
                required int slotId,
                required String completedAtIso,
              }) => PrayerCompletionsCompanion.insert(
                id: id,
                dateYmd: dateYmd,
                slotId: slotId,
                completedAtIso: completedAtIso,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrayerCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerCompletionsTable,
      PrayerCompletion,
      $$PrayerCompletionsTableFilterComposer,
      $$PrayerCompletionsTableOrderingComposer,
      $$PrayerCompletionsTableAnnotationComposer,
      $$PrayerCompletionsTableCreateCompanionBuilder,
      $$PrayerCompletionsTableUpdateCompanionBuilder,
      (
        PrayerCompletion,
        BaseReferences<
          _$AppDatabase,
          $PrayerCompletionsTable,
          PrayerCompletion
        >,
      ),
      PrayerCompletion,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
  $$SavedItemsTableTableManager get savedItems =>
      $$SavedItemsTableTableManager(_db, _db.savedItems);
  $$ReadingProgressTableTableManager get readingProgress =>
      $$ReadingProgressTableTableManager(_db, _db.readingProgress);
  $$StreakTasksTableTableManager get streakTasks =>
      $$StreakTasksTableTableManager(_db, _db.streakTasks);
  $$StreakEventsTableTableManager get streakEvents =>
      $$StreakEventsTableTableManager(_db, _db.streakEvents);
  $$PrayerScheduleTableTableManager get prayerSchedule =>
      $$PrayerScheduleTableTableManager(_db, _db.prayerSchedule);
  $$PrayerCompletionsTableTableManager get prayerCompletions =>
      $$PrayerCompletionsTableTableManager(_db, _db.prayerCompletions);
}
