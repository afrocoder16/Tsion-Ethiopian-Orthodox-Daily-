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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, kind, createdAtIso, body];
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
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
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
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
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
  final String? body;
  const SavedItem({
    required this.id,
    required this.title,
    required this.kind,
    required this.createdAtIso,
    this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['kind'] = Variable<String>(kind);
    map['created_at_iso'] = Variable<String>(createdAtIso);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    return map;
  }

  SavedItemsCompanion toCompanion(bool nullToAbsent) {
    return SavedItemsCompanion(
      id: Value(id),
      title: Value(title),
      kind: Value(kind),
      createdAtIso: Value(createdAtIso),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
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
      body: serializer.fromJson<String?>(json['body']),
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
      'body': serializer.toJson<String?>(body),
    };
  }

  SavedItem copyWith({
    String? id,
    String? title,
    String? kind,
    String? createdAtIso,
    Value<String?> body = const Value.absent(),
  }) => SavedItem(
    id: id ?? this.id,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    createdAtIso: createdAtIso ?? this.createdAtIso,
    body: body.present ? body.value : this.body,
  );
  SavedItem copyWithCompanion(SavedItemsCompanion data) {
    return SavedItem(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAtIso: data.createdAtIso.present
          ? data.createdAtIso.value
          : this.createdAtIso,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedItem(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('createdAtIso: $createdAtIso, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, kind, createdAtIso, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedItem &&
          other.id == this.id &&
          other.title == this.title &&
          other.kind == this.kind &&
          other.createdAtIso == this.createdAtIso &&
          other.body == this.body);
}

class SavedItemsCompanion extends UpdateCompanion<SavedItem> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> kind;
  final Value<String> createdAtIso;
  final Value<String?> body;
  final Value<int> rowid;
  const SavedItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAtIso = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedItemsCompanion.insert({
    required String id,
    required String title,
    required String kind,
    required String createdAtIso,
    this.body = const Value.absent(),
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
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (kind != null) 'kind': kind,
      if (createdAtIso != null) 'created_at_iso': createdAtIso,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? kind,
    Value<String>? createdAtIso,
    Value<String?>? body,
    Value<int>? rowid,
  }) {
    return SavedItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      body: body ?? this.body,
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
    if (body.present) {
      map['body'] = Variable<String>(body.value);
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
          ..write('body: $body, ')
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
  static const VerificationMeta _isBonusMeta = const VerificationMeta(
    'isBonus',
  );
  @override
  late final GeneratedColumn<bool> isBonus = GeneratedColumn<bool>(
    'is_bonus',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bonus" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [taskId, title, isRequired, isBonus];
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
    if (data.containsKey('is_bonus')) {
      context.handle(
        _isBonusMeta,
        isBonus.isAcceptableOrUnknown(data['is_bonus']!, _isBonusMeta),
      );
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
      isBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bonus'],
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
  final bool isBonus;
  const StreakTask({
    required this.taskId,
    required this.title,
    required this.isRequired,
    required this.isBonus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    map['is_required'] = Variable<bool>(isRequired);
    map['is_bonus'] = Variable<bool>(isBonus);
    return map;
  }

  StreakTasksCompanion toCompanion(bool nullToAbsent) {
    return StreakTasksCompanion(
      taskId: Value(taskId),
      title: Value(title),
      isRequired: Value(isRequired),
      isBonus: Value(isBonus),
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
      isBonus: serializer.fromJson<bool>(json['isBonus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'isRequired': serializer.toJson<bool>(isRequired),
      'isBonus': serializer.toJson<bool>(isBonus),
    };
  }

  StreakTask copyWith({
    String? taskId,
    String? title,
    bool? isRequired,
    bool? isBonus,
  }) => StreakTask(
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    isRequired: isRequired ?? this.isRequired,
    isBonus: isBonus ?? this.isBonus,
  );
  StreakTask copyWithCompanion(StreakTasksCompanion data) {
    return StreakTask(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      isRequired: data.isRequired.present
          ? data.isRequired.value
          : this.isRequired,
      isBonus: data.isBonus.present ? data.isBonus.value : this.isBonus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakTask(')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isRequired: $isRequired, ')
          ..write('isBonus: $isBonus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, title, isRequired, isBonus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakTask &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.isRequired == this.isRequired &&
          other.isBonus == this.isBonus);
}

class StreakTasksCompanion extends UpdateCompanion<StreakTask> {
  final Value<String> taskId;
  final Value<String> title;
  final Value<bool> isRequired;
  final Value<bool> isBonus;
  final Value<int> rowid;
  const StreakTasksCompanion({
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.isBonus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StreakTasksCompanion.insert({
    required String taskId,
    required String title,
    required bool isRequired,
    this.isBonus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       title = Value(title),
       isRequired = Value(isRequired);
  static Insertable<StreakTask> custom({
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<bool>? isRequired,
    Expression<bool>? isBonus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (isRequired != null) 'is_required': isRequired,
      if (isBonus != null) 'is_bonus': isBonus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StreakTasksCompanion copyWith({
    Value<String>? taskId,
    Value<String>? title,
    Value<bool>? isRequired,
    Value<bool>? isBonus,
    Value<int>? rowid,
  }) {
    return StreakTasksCompanion(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isRequired: isRequired ?? this.isRequired,
      isBonus: isBonus ?? this.isBonus,
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
    if (isBonus.present) {
      map['is_bonus'] = Variable<bool>(isBonus.value);
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
          ..write('isBonus: $isBonus, ')
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

class $PersonalPrayersTable extends PersonalPrayers
    with TableInfo<$PersonalPrayersTable, PersonalPrayer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalPrayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _intentionMeta = const VerificationMeta(
    'intention',
  );
  @override
  late final GeneratedColumn<String> intention = GeneratedColumn<String>(
    'intention',
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
  static const VerificationMeta _dueAtIsoMeta = const VerificationMeta(
    'dueAtIso',
  );
  @override
  late final GeneratedColumn<String> dueAtIso = GeneratedColumn<String>(
    'due_at_iso',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    intention,
    createdAtIso,
    updatedAtIso,
    dueAtIso,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_prayers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalPrayer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('intention')) {
      context.handle(
        _intentionMeta,
        intention.isAcceptableOrUnknown(data['intention']!, _intentionMeta),
      );
    } else if (isInserting) {
      context.missing(_intentionMeta);
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
    if (data.containsKey('due_at_iso')) {
      context.handle(
        _dueAtIsoMeta,
        dueAtIso.isAcceptableOrUnknown(data['due_at_iso']!, _dueAtIsoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalPrayer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalPrayer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      intention: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intention'],
      )!,
      createdAtIso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_iso'],
      )!,
      updatedAtIso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_iso'],
      )!,
      dueAtIso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_at_iso'],
      ),
    );
  }

  @override
  $PersonalPrayersTable createAlias(String alias) {
    return $PersonalPrayersTable(attachedDatabase, alias);
  }
}

class PersonalPrayer extends DataClass implements Insertable<PersonalPrayer> {
  final String id;
  final String name;
  final String intention;
  final String createdAtIso;
  final String updatedAtIso;
  final String? dueAtIso;
  const PersonalPrayer({
    required this.id,
    required this.name,
    required this.intention,
    required this.createdAtIso,
    required this.updatedAtIso,
    this.dueAtIso,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['intention'] = Variable<String>(intention);
    map['created_at_iso'] = Variable<String>(createdAtIso);
    map['updated_at_iso'] = Variable<String>(updatedAtIso);
    if (!nullToAbsent || dueAtIso != null) {
      map['due_at_iso'] = Variable<String>(dueAtIso);
    }
    return map;
  }

  PersonalPrayersCompanion toCompanion(bool nullToAbsent) {
    return PersonalPrayersCompanion(
      id: Value(id),
      name: Value(name),
      intention: Value(intention),
      createdAtIso: Value(createdAtIso),
      updatedAtIso: Value(updatedAtIso),
      dueAtIso: dueAtIso == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAtIso),
    );
  }

  factory PersonalPrayer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalPrayer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      intention: serializer.fromJson<String>(json['intention']),
      createdAtIso: serializer.fromJson<String>(json['createdAtIso']),
      updatedAtIso: serializer.fromJson<String>(json['updatedAtIso']),
      dueAtIso: serializer.fromJson<String?>(json['dueAtIso']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'intention': serializer.toJson<String>(intention),
      'createdAtIso': serializer.toJson<String>(createdAtIso),
      'updatedAtIso': serializer.toJson<String>(updatedAtIso),
      'dueAtIso': serializer.toJson<String?>(dueAtIso),
    };
  }

  PersonalPrayer copyWith({
    String? id,
    String? name,
    String? intention,
    String? createdAtIso,
    String? updatedAtIso,
    Value<String?> dueAtIso = const Value.absent(),
  }) => PersonalPrayer(
    id: id ?? this.id,
    name: name ?? this.name,
    intention: intention ?? this.intention,
    createdAtIso: createdAtIso ?? this.createdAtIso,
    updatedAtIso: updatedAtIso ?? this.updatedAtIso,
    dueAtIso: dueAtIso.present ? dueAtIso.value : this.dueAtIso,
  );
  PersonalPrayer copyWithCompanion(PersonalPrayersCompanion data) {
    return PersonalPrayer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      intention: data.intention.present ? data.intention.value : this.intention,
      createdAtIso: data.createdAtIso.present
          ? data.createdAtIso.value
          : this.createdAtIso,
      updatedAtIso: data.updatedAtIso.present
          ? data.updatedAtIso.value
          : this.updatedAtIso,
      dueAtIso: data.dueAtIso.present ? data.dueAtIso.value : this.dueAtIso,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalPrayer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('intention: $intention, ')
          ..write('createdAtIso: $createdAtIso, ')
          ..write('updatedAtIso: $updatedAtIso, ')
          ..write('dueAtIso: $dueAtIso')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, intention, createdAtIso, updatedAtIso, dueAtIso);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalPrayer &&
          other.id == this.id &&
          other.name == this.name &&
          other.intention == this.intention &&
          other.createdAtIso == this.createdAtIso &&
          other.updatedAtIso == this.updatedAtIso &&
          other.dueAtIso == this.dueAtIso);
}

class PersonalPrayersCompanion extends UpdateCompanion<PersonalPrayer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> intention;
  final Value<String> createdAtIso;
  final Value<String> updatedAtIso;
  final Value<String?> dueAtIso;
  final Value<int> rowid;
  const PersonalPrayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.intention = const Value.absent(),
    this.createdAtIso = const Value.absent(),
    this.updatedAtIso = const Value.absent(),
    this.dueAtIso = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalPrayersCompanion.insert({
    required String id,
    required String name,
    required String intention,
    required String createdAtIso,
    required String updatedAtIso,
    this.dueAtIso = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       intention = Value(intention),
       createdAtIso = Value(createdAtIso),
       updatedAtIso = Value(updatedAtIso);
  static Insertable<PersonalPrayer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? intention,
    Expression<String>? createdAtIso,
    Expression<String>? updatedAtIso,
    Expression<String>? dueAtIso,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (intention != null) 'intention': intention,
      if (createdAtIso != null) 'created_at_iso': createdAtIso,
      if (updatedAtIso != null) 'updated_at_iso': updatedAtIso,
      if (dueAtIso != null) 'due_at_iso': dueAtIso,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalPrayersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? intention,
    Value<String>? createdAtIso,
    Value<String>? updatedAtIso,
    Value<String?>? dueAtIso,
    Value<int>? rowid,
  }) {
    return PersonalPrayersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      intention: intention ?? this.intention,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      dueAtIso: dueAtIso ?? this.dueAtIso,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (intention.present) {
      map['intention'] = Variable<String>(intention.value);
    }
    if (createdAtIso.present) {
      map['created_at_iso'] = Variable<String>(createdAtIso.value);
    }
    if (updatedAtIso.present) {
      map['updated_at_iso'] = Variable<String>(updatedAtIso.value);
    }
    if (dueAtIso.present) {
      map['due_at_iso'] = Variable<String>(dueAtIso.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalPrayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('intention: $intention, ')
          ..write('createdAtIso: $createdAtIso, ')
          ..write('updatedAtIso: $updatedAtIso, ')
          ..write('dueAtIso: $dueAtIso, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BibleBooksTable extends BibleBooks
    with TableInfo<$BibleBooksTable, BibleBookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BibleBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonIdMeta = const VerificationMeta(
    'canonId',
  );
  @override
  late final GeneratedColumn<String> canonId = GeneratedColumn<String>(
    'canon_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _testamentMeta = const VerificationMeta(
    'testament',
  );
  @override
  late final GeneratedColumn<String> testament = GeneratedColumn<String>(
    'testament',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameAmMeta = const VerificationMeta('nameAm');
  @override
  late final GeneratedColumn<String> nameAm = GeneratedColumn<String>(
    'name_am',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _abbrevEnMeta = const VerificationMeta(
    'abbrevEn',
  );
  @override
  late final GeneratedColumn<String> abbrevEn = GeneratedColumn<String>(
    'abbrev_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _abbrevAmMeta = const VerificationMeta(
    'abbrevAm',
  );
  @override
  late final GeneratedColumn<String> abbrevAm = GeneratedColumn<String>(
    'abbrev_am',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chaptersMeta = const VerificationMeta(
    'chapters',
  );
  @override
  late final GeneratedColumn<int> chapters = GeneratedColumn<int>(
    'chapters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    canonId,
    testament,
    orderIndex,
    nameEn,
    nameAm,
    abbrevEn,
    abbrevAm,
    chapters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bible_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<BibleBookRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('canon_id')) {
      context.handle(
        _canonIdMeta,
        canonId.isAcceptableOrUnknown(data['canon_id']!, _canonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_canonIdMeta);
    }
    if (data.containsKey('testament')) {
      context.handle(
        _testamentMeta,
        testament.isAcceptableOrUnknown(data['testament']!, _testamentMeta),
      );
    } else if (isInserting) {
      context.missing(_testamentMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_am')) {
      context.handle(
        _nameAmMeta,
        nameAm.isAcceptableOrUnknown(data['name_am']!, _nameAmMeta),
      );
    } else if (isInserting) {
      context.missing(_nameAmMeta);
    }
    if (data.containsKey('abbrev_en')) {
      context.handle(
        _abbrevEnMeta,
        abbrevEn.isAcceptableOrUnknown(data['abbrev_en']!, _abbrevEnMeta),
      );
    } else if (isInserting) {
      context.missing(_abbrevEnMeta);
    }
    if (data.containsKey('abbrev_am')) {
      context.handle(
        _abbrevAmMeta,
        abbrevAm.isAcceptableOrUnknown(data['abbrev_am']!, _abbrevAmMeta),
      );
    } else if (isInserting) {
      context.missing(_abbrevAmMeta);
    }
    if (data.containsKey('chapters')) {
      context.handle(
        _chaptersMeta,
        chapters.isAcceptableOrUnknown(data['chapters']!, _chaptersMeta),
      );
    } else if (isInserting) {
      context.missing(_chaptersMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BibleBookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BibleBookRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      canonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canon_id'],
      )!,
      testament: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}testament'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      nameAm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_am'],
      )!,
      abbrevEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abbrev_en'],
      )!,
      abbrevAm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abbrev_am'],
      )!,
      chapters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapters'],
      )!,
    );
  }

  @override
  $BibleBooksTable createAlias(String alias) {
    return $BibleBooksTable(attachedDatabase, alias);
  }
}

class BibleBookRow extends DataClass implements Insertable<BibleBookRow> {
  final String id;
  final String canonId;
  final String testament;
  final int orderIndex;
  final String nameEn;
  final String nameAm;
  final String abbrevEn;
  final String abbrevAm;
  final int chapters;
  const BibleBookRow({
    required this.id,
    required this.canonId,
    required this.testament,
    required this.orderIndex,
    required this.nameEn,
    required this.nameAm,
    required this.abbrevEn,
    required this.abbrevAm,
    required this.chapters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['canon_id'] = Variable<String>(canonId);
    map['testament'] = Variable<String>(testament);
    map['order_index'] = Variable<int>(orderIndex);
    map['name_en'] = Variable<String>(nameEn);
    map['name_am'] = Variable<String>(nameAm);
    map['abbrev_en'] = Variable<String>(abbrevEn);
    map['abbrev_am'] = Variable<String>(abbrevAm);
    map['chapters'] = Variable<int>(chapters);
    return map;
  }

  BibleBooksCompanion toCompanion(bool nullToAbsent) {
    return BibleBooksCompanion(
      id: Value(id),
      canonId: Value(canonId),
      testament: Value(testament),
      orderIndex: Value(orderIndex),
      nameEn: Value(nameEn),
      nameAm: Value(nameAm),
      abbrevEn: Value(abbrevEn),
      abbrevAm: Value(abbrevAm),
      chapters: Value(chapters),
    );
  }

  factory BibleBookRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BibleBookRow(
      id: serializer.fromJson<String>(json['id']),
      canonId: serializer.fromJson<String>(json['canonId']),
      testament: serializer.fromJson<String>(json['testament']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameAm: serializer.fromJson<String>(json['nameAm']),
      abbrevEn: serializer.fromJson<String>(json['abbrevEn']),
      abbrevAm: serializer.fromJson<String>(json['abbrevAm']),
      chapters: serializer.fromJson<int>(json['chapters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'canonId': serializer.toJson<String>(canonId),
      'testament': serializer.toJson<String>(testament),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameAm': serializer.toJson<String>(nameAm),
      'abbrevEn': serializer.toJson<String>(abbrevEn),
      'abbrevAm': serializer.toJson<String>(abbrevAm),
      'chapters': serializer.toJson<int>(chapters),
    };
  }

  BibleBookRow copyWith({
    String? id,
    String? canonId,
    String? testament,
    int? orderIndex,
    String? nameEn,
    String? nameAm,
    String? abbrevEn,
    String? abbrevAm,
    int? chapters,
  }) => BibleBookRow(
    id: id ?? this.id,
    canonId: canonId ?? this.canonId,
    testament: testament ?? this.testament,
    orderIndex: orderIndex ?? this.orderIndex,
    nameEn: nameEn ?? this.nameEn,
    nameAm: nameAm ?? this.nameAm,
    abbrevEn: abbrevEn ?? this.abbrevEn,
    abbrevAm: abbrevAm ?? this.abbrevAm,
    chapters: chapters ?? this.chapters,
  );
  BibleBookRow copyWithCompanion(BibleBooksCompanion data) {
    return BibleBookRow(
      id: data.id.present ? data.id.value : this.id,
      canonId: data.canonId.present ? data.canonId.value : this.canonId,
      testament: data.testament.present ? data.testament.value : this.testament,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameAm: data.nameAm.present ? data.nameAm.value : this.nameAm,
      abbrevEn: data.abbrevEn.present ? data.abbrevEn.value : this.abbrevEn,
      abbrevAm: data.abbrevAm.present ? data.abbrevAm.value : this.abbrevAm,
      chapters: data.chapters.present ? data.chapters.value : this.chapters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BibleBookRow(')
          ..write('id: $id, ')
          ..write('canonId: $canonId, ')
          ..write('testament: $testament, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameAm: $nameAm, ')
          ..write('abbrevEn: $abbrevEn, ')
          ..write('abbrevAm: $abbrevAm, ')
          ..write('chapters: $chapters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    canonId,
    testament,
    orderIndex,
    nameEn,
    nameAm,
    abbrevEn,
    abbrevAm,
    chapters,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BibleBookRow &&
          other.id == this.id &&
          other.canonId == this.canonId &&
          other.testament == this.testament &&
          other.orderIndex == this.orderIndex &&
          other.nameEn == this.nameEn &&
          other.nameAm == this.nameAm &&
          other.abbrevEn == this.abbrevEn &&
          other.abbrevAm == this.abbrevAm &&
          other.chapters == this.chapters);
}

class BibleBooksCompanion extends UpdateCompanion<BibleBookRow> {
  final Value<String> id;
  final Value<String> canonId;
  final Value<String> testament;
  final Value<int> orderIndex;
  final Value<String> nameEn;
  final Value<String> nameAm;
  final Value<String> abbrevEn;
  final Value<String> abbrevAm;
  final Value<int> chapters;
  final Value<int> rowid;
  const BibleBooksCompanion({
    this.id = const Value.absent(),
    this.canonId = const Value.absent(),
    this.testament = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameAm = const Value.absent(),
    this.abbrevEn = const Value.absent(),
    this.abbrevAm = const Value.absent(),
    this.chapters = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BibleBooksCompanion.insert({
    required String id,
    required String canonId,
    required String testament,
    required int orderIndex,
    required String nameEn,
    required String nameAm,
    required String abbrevEn,
    required String abbrevAm,
    required int chapters,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       canonId = Value(canonId),
       testament = Value(testament),
       orderIndex = Value(orderIndex),
       nameEn = Value(nameEn),
       nameAm = Value(nameAm),
       abbrevEn = Value(abbrevEn),
       abbrevAm = Value(abbrevAm),
       chapters = Value(chapters);
  static Insertable<BibleBookRow> custom({
    Expression<String>? id,
    Expression<String>? canonId,
    Expression<String>? testament,
    Expression<int>? orderIndex,
    Expression<String>? nameEn,
    Expression<String>? nameAm,
    Expression<String>? abbrevEn,
    Expression<String>? abbrevAm,
    Expression<int>? chapters,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (canonId != null) 'canon_id': canonId,
      if (testament != null) 'testament': testament,
      if (orderIndex != null) 'order_index': orderIndex,
      if (nameEn != null) 'name_en': nameEn,
      if (nameAm != null) 'name_am': nameAm,
      if (abbrevEn != null) 'abbrev_en': abbrevEn,
      if (abbrevAm != null) 'abbrev_am': abbrevAm,
      if (chapters != null) 'chapters': chapters,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BibleBooksCompanion copyWith({
    Value<String>? id,
    Value<String>? canonId,
    Value<String>? testament,
    Value<int>? orderIndex,
    Value<String>? nameEn,
    Value<String>? nameAm,
    Value<String>? abbrevEn,
    Value<String>? abbrevAm,
    Value<int>? chapters,
    Value<int>? rowid,
  }) {
    return BibleBooksCompanion(
      id: id ?? this.id,
      canonId: canonId ?? this.canonId,
      testament: testament ?? this.testament,
      orderIndex: orderIndex ?? this.orderIndex,
      nameEn: nameEn ?? this.nameEn,
      nameAm: nameAm ?? this.nameAm,
      abbrevEn: abbrevEn ?? this.abbrevEn,
      abbrevAm: abbrevAm ?? this.abbrevAm,
      chapters: chapters ?? this.chapters,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (canonId.present) {
      map['canon_id'] = Variable<String>(canonId.value);
    }
    if (testament.present) {
      map['testament'] = Variable<String>(testament.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameAm.present) {
      map['name_am'] = Variable<String>(nameAm.value);
    }
    if (abbrevEn.present) {
      map['abbrev_en'] = Variable<String>(abbrevEn.value);
    }
    if (abbrevAm.present) {
      map['abbrev_am'] = Variable<String>(abbrevAm.value);
    }
    if (chapters.present) {
      map['chapters'] = Variable<int>(chapters.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BibleBooksCompanion(')
          ..write('id: $id, ')
          ..write('canonId: $canonId, ')
          ..write('testament: $testament, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameAm: $nameAm, ')
          ..write('abbrevEn: $abbrevEn, ')
          ..write('abbrevAm: $abbrevAm, ')
          ..write('chapters: $chapters, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BibleVersesTable extends BibleVerses
    with TableInfo<$BibleVersesTable, BibleVerseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BibleVersesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
    'verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textEnMeta = const VerificationMeta('textEn');
  @override
  late final GeneratedColumn<String> textEn = GeneratedColumn<String>(
    'text_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textAmMeta = const VerificationMeta('textAm');
  @override
  late final GeneratedColumn<String> textAm = GeneratedColumn<String>(
    'text_am',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookId,
    chapter,
    verse,
    textEn,
    textAm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bible_verses';
  @override
  VerificationContext validateIntegrity(
    Insertable<BibleVerseRow> instance, {
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
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('text_en')) {
      context.handle(
        _textEnMeta,
        textEn.isAcceptableOrUnknown(data['text_en']!, _textEnMeta),
      );
    } else if (isInserting) {
      context.missing(_textEnMeta);
    }
    if (data.containsKey('text_am')) {
      context.handle(
        _textAmMeta,
        textAm.isAcceptableOrUnknown(data['text_am']!, _textAmMeta),
      );
    } else if (isInserting) {
      context.missing(_textAmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, chapter, verse};
  @override
  BibleVerseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BibleVerseRow(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse'],
      )!,
      textEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_en'],
      )!,
      textAm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_am'],
      )!,
    );
  }

  @override
  $BibleVersesTable createAlias(String alias) {
    return $BibleVersesTable(attachedDatabase, alias);
  }
}

class BibleVerseRow extends DataClass implements Insertable<BibleVerseRow> {
  final String bookId;
  final int chapter;
  final int verse;
  final String textEn;
  final String textAm;
  const BibleVerseRow({
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.textEn,
    required this.textAm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['chapter'] = Variable<int>(chapter);
    map['verse'] = Variable<int>(verse);
    map['text_en'] = Variable<String>(textEn);
    map['text_am'] = Variable<String>(textAm);
    return map;
  }

  BibleVersesCompanion toCompanion(bool nullToAbsent) {
    return BibleVersesCompanion(
      bookId: Value(bookId),
      chapter: Value(chapter),
      verse: Value(verse),
      textEn: Value(textEn),
      textAm: Value(textAm),
    );
  }

  factory BibleVerseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BibleVerseRow(
      bookId: serializer.fromJson<String>(json['bookId']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verse: serializer.fromJson<int>(json['verse']),
      textEn: serializer.fromJson<String>(json['textEn']),
      textAm: serializer.fromJson<String>(json['textAm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'chapter': serializer.toJson<int>(chapter),
      'verse': serializer.toJson<int>(verse),
      'textEn': serializer.toJson<String>(textEn),
      'textAm': serializer.toJson<String>(textAm),
    };
  }

  BibleVerseRow copyWith({
    String? bookId,
    int? chapter,
    int? verse,
    String? textEn,
    String? textAm,
  }) => BibleVerseRow(
    bookId: bookId ?? this.bookId,
    chapter: chapter ?? this.chapter,
    verse: verse ?? this.verse,
    textEn: textEn ?? this.textEn,
    textAm: textAm ?? this.textAm,
  );
  BibleVerseRow copyWithCompanion(BibleVersesCompanion data) {
    return BibleVerseRow(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verse: data.verse.present ? data.verse.value : this.verse,
      textEn: data.textEn.present ? data.textEn.value : this.textEn,
      textAm: data.textAm.present ? data.textAm.value : this.textAm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BibleVerseRow(')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('textEn: $textEn, ')
          ..write('textAm: $textAm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, chapter, verse, textEn, textAm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BibleVerseRow &&
          other.bookId == this.bookId &&
          other.chapter == this.chapter &&
          other.verse == this.verse &&
          other.textEn == this.textEn &&
          other.textAm == this.textAm);
}

class BibleVersesCompanion extends UpdateCompanion<BibleVerseRow> {
  final Value<String> bookId;
  final Value<int> chapter;
  final Value<int> verse;
  final Value<String> textEn;
  final Value<String> textAm;
  final Value<int> rowid;
  const BibleVersesCompanion({
    this.bookId = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verse = const Value.absent(),
    this.textEn = const Value.absent(),
    this.textAm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BibleVersesCompanion.insert({
    required String bookId,
    required int chapter,
    required int verse,
    required String textEn,
    required String textAm,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       chapter = Value(chapter),
       verse = Value(verse),
       textEn = Value(textEn),
       textAm = Value(textAm);
  static Insertable<BibleVerseRow> custom({
    Expression<String>? bookId,
    Expression<int>? chapter,
    Expression<int>? verse,
    Expression<String>? textEn,
    Expression<String>? textAm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (textEn != null) 'text_en': textEn,
      if (textAm != null) 'text_am': textAm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BibleVersesCompanion copyWith({
    Value<String>? bookId,
    Value<int>? chapter,
    Value<int>? verse,
    Value<String>? textEn,
    Value<String>? textAm,
    Value<int>? rowid,
  }) {
    return BibleVersesCompanion(
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      textEn: textEn ?? this.textEn,
      textAm: textAm ?? this.textAm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verse.present) {
      map['verse'] = Variable<int>(verse.value);
    }
    if (textEn.present) {
      map['text_en'] = Variable<String>(textEn.value);
    }
    if (textAm.present) {
      map['text_am'] = Variable<String>(textAm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BibleVersesCompanion(')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('textEn: $textEn, ')
          ..write('textAm: $textAm, ')
          ..write('rowid: $rowid')
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
  late final $PersonalPrayersTable personalPrayers = $PersonalPrayersTable(
    this,
  );
  late final $BibleBooksTable bibleBooks = $BibleBooksTable(this);
  late final $BibleVersesTable bibleVerses = $BibleVersesTable(this);
  late final MetaDao metaDao = MetaDao(this as AppDatabase);
  late final SavedItemsDao savedItemsDao = SavedItemsDao(this as AppDatabase);
  late final ReadingProgressDao readingProgressDao = ReadingProgressDao(
    this as AppDatabase,
  );
  late final StreakDao streakDao = StreakDao(this as AppDatabase);
  late final PrayerDao prayerDao = PrayerDao(this as AppDatabase);
  late final PersonalPrayersDao personalPrayersDao = PersonalPrayersDao(
    this as AppDatabase,
  );
  late final BibleDao bibleDao = BibleDao(this as AppDatabase);
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
    personalPrayers,
    bibleBooks,
    bibleVerses,
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
      Value<String?> body,
      Value<int> rowid,
    });
typedef $$SavedItemsTableUpdateCompanionBuilder =
    SavedItemsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> kind,
      Value<String> createdAtIso,
      Value<String?> body,
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

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
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

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
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

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
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
                Value<String?> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedItemsCompanion(
                id: id,
                title: title,
                kind: kind,
                createdAtIso: createdAtIso,
                body: body,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String kind,
                required String createdAtIso,
                Value<String?> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedItemsCompanion.insert(
                id: id,
                title: title,
                kind: kind,
                createdAtIso: createdAtIso,
                body: body,
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
      Value<bool> isBonus,
      Value<int> rowid,
    });
typedef $$StreakTasksTableUpdateCompanionBuilder =
    StreakTasksCompanion Function({
      Value<String> taskId,
      Value<String> title,
      Value<bool> isRequired,
      Value<bool> isBonus,
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

  ColumnFilters<bool> get isBonus => $composableBuilder(
    column: $table.isBonus,
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

  ColumnOrderings<bool> get isBonus => $composableBuilder(
    column: $table.isBonus,
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

  GeneratedColumn<bool> get isBonus =>
      $composableBuilder(column: $table.isBonus, builder: (column) => column);
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
                Value<bool> isBonus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StreakTasksCompanion(
                taskId: taskId,
                title: title,
                isRequired: isRequired,
                isBonus: isBonus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String taskId,
                required String title,
                required bool isRequired,
                Value<bool> isBonus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StreakTasksCompanion.insert(
                taskId: taskId,
                title: title,
                isRequired: isRequired,
                isBonus: isBonus,
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
typedef $$PersonalPrayersTableCreateCompanionBuilder =
    PersonalPrayersCompanion Function({
      required String id,
      required String name,
      required String intention,
      required String createdAtIso,
      required String updatedAtIso,
      Value<String?> dueAtIso,
      Value<int> rowid,
    });
typedef $$PersonalPrayersTableUpdateCompanionBuilder =
    PersonalPrayersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> intention,
      Value<String> createdAtIso,
      Value<String> updatedAtIso,
      Value<String?> dueAtIso,
      Value<int> rowid,
    });

class $$PersonalPrayersTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalPrayersTable> {
  $$PersonalPrayersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intention => $composableBuilder(
    column: $table.intention,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAtIso => $composableBuilder(
    column: $table.createdAtIso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtIso => $composableBuilder(
    column: $table.updatedAtIso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueAtIso => $composableBuilder(
    column: $table.dueAtIso,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonalPrayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalPrayersTable> {
  $$PersonalPrayersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intention => $composableBuilder(
    column: $table.intention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAtIso => $composableBuilder(
    column: $table.createdAtIso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtIso => $composableBuilder(
    column: $table.updatedAtIso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueAtIso => $composableBuilder(
    column: $table.dueAtIso,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalPrayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalPrayersTable> {
  $$PersonalPrayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get intention =>
      $composableBuilder(column: $table.intention, builder: (column) => column);

  GeneratedColumn<String> get createdAtIso => $composableBuilder(
    column: $table.createdAtIso,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtIso => $composableBuilder(
    column: $table.updatedAtIso,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueAtIso =>
      $composableBuilder(column: $table.dueAtIso, builder: (column) => column);
}

class $$PersonalPrayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalPrayersTable,
          PersonalPrayer,
          $$PersonalPrayersTableFilterComposer,
          $$PersonalPrayersTableOrderingComposer,
          $$PersonalPrayersTableAnnotationComposer,
          $$PersonalPrayersTableCreateCompanionBuilder,
          $$PersonalPrayersTableUpdateCompanionBuilder,
          (
            PersonalPrayer,
            BaseReferences<
              _$AppDatabase,
              $PersonalPrayersTable,
              PersonalPrayer
            >,
          ),
          PersonalPrayer,
          PrefetchHooks Function()
        > {
  $$PersonalPrayersTableTableManager(
    _$AppDatabase db,
    $PersonalPrayersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalPrayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalPrayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalPrayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> intention = const Value.absent(),
                Value<String> createdAtIso = const Value.absent(),
                Value<String> updatedAtIso = const Value.absent(),
                Value<String?> dueAtIso = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalPrayersCompanion(
                id: id,
                name: name,
                intention: intention,
                createdAtIso: createdAtIso,
                updatedAtIso: updatedAtIso,
                dueAtIso: dueAtIso,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String intention,
                required String createdAtIso,
                required String updatedAtIso,
                Value<String?> dueAtIso = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalPrayersCompanion.insert(
                id: id,
                name: name,
                intention: intention,
                createdAtIso: createdAtIso,
                updatedAtIso: updatedAtIso,
                dueAtIso: dueAtIso,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalPrayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalPrayersTable,
      PersonalPrayer,
      $$PersonalPrayersTableFilterComposer,
      $$PersonalPrayersTableOrderingComposer,
      $$PersonalPrayersTableAnnotationComposer,
      $$PersonalPrayersTableCreateCompanionBuilder,
      $$PersonalPrayersTableUpdateCompanionBuilder,
      (
        PersonalPrayer,
        BaseReferences<_$AppDatabase, $PersonalPrayersTable, PersonalPrayer>,
      ),
      PersonalPrayer,
      PrefetchHooks Function()
    >;
typedef $$BibleBooksTableCreateCompanionBuilder =
    BibleBooksCompanion Function({
      required String id,
      required String canonId,
      required String testament,
      required int orderIndex,
      required String nameEn,
      required String nameAm,
      required String abbrevEn,
      required String abbrevAm,
      required int chapters,
      Value<int> rowid,
    });
typedef $$BibleBooksTableUpdateCompanionBuilder =
    BibleBooksCompanion Function({
      Value<String> id,
      Value<String> canonId,
      Value<String> testament,
      Value<int> orderIndex,
      Value<String> nameEn,
      Value<String> nameAm,
      Value<String> abbrevEn,
      Value<String> abbrevAm,
      Value<int> chapters,
      Value<int> rowid,
    });

class $$BibleBooksTableFilterComposer
    extends Composer<_$AppDatabase, $BibleBooksTable> {
  $$BibleBooksTableFilterComposer({
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

  ColumnFilters<String> get canonId => $composableBuilder(
    column: $table.canonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testament => $composableBuilder(
    column: $table.testament,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAm => $composableBuilder(
    column: $table.nameAm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abbrevEn => $composableBuilder(
    column: $table.abbrevEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abbrevAm => $composableBuilder(
    column: $table.abbrevAm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapters => $composableBuilder(
    column: $table.chapters,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BibleBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BibleBooksTable> {
  $$BibleBooksTableOrderingComposer({
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

  ColumnOrderings<String> get canonId => $composableBuilder(
    column: $table.canonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testament => $composableBuilder(
    column: $table.testament,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAm => $composableBuilder(
    column: $table.nameAm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abbrevEn => $composableBuilder(
    column: $table.abbrevEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abbrevAm => $composableBuilder(
    column: $table.abbrevAm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapters => $composableBuilder(
    column: $table.chapters,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BibleBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BibleBooksTable> {
  $$BibleBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get canonId =>
      $composableBuilder(column: $table.canonId, builder: (column) => column);

  GeneratedColumn<String> get testament =>
      $composableBuilder(column: $table.testament, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameAm =>
      $composableBuilder(column: $table.nameAm, builder: (column) => column);

  GeneratedColumn<String> get abbrevEn =>
      $composableBuilder(column: $table.abbrevEn, builder: (column) => column);

  GeneratedColumn<String> get abbrevAm =>
      $composableBuilder(column: $table.abbrevAm, builder: (column) => column);

  GeneratedColumn<int> get chapters =>
      $composableBuilder(column: $table.chapters, builder: (column) => column);
}

class $$BibleBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BibleBooksTable,
          BibleBookRow,
          $$BibleBooksTableFilterComposer,
          $$BibleBooksTableOrderingComposer,
          $$BibleBooksTableAnnotationComposer,
          $$BibleBooksTableCreateCompanionBuilder,
          $$BibleBooksTableUpdateCompanionBuilder,
          (
            BibleBookRow,
            BaseReferences<_$AppDatabase, $BibleBooksTable, BibleBookRow>,
          ),
          BibleBookRow,
          PrefetchHooks Function()
        > {
  $$BibleBooksTableTableManager(_$AppDatabase db, $BibleBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BibleBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BibleBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BibleBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> canonId = const Value.absent(),
                Value<String> testament = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> nameAm = const Value.absent(),
                Value<String> abbrevEn = const Value.absent(),
                Value<String> abbrevAm = const Value.absent(),
                Value<int> chapters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BibleBooksCompanion(
                id: id,
                canonId: canonId,
                testament: testament,
                orderIndex: orderIndex,
                nameEn: nameEn,
                nameAm: nameAm,
                abbrevEn: abbrevEn,
                abbrevAm: abbrevAm,
                chapters: chapters,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String canonId,
                required String testament,
                required int orderIndex,
                required String nameEn,
                required String nameAm,
                required String abbrevEn,
                required String abbrevAm,
                required int chapters,
                Value<int> rowid = const Value.absent(),
              }) => BibleBooksCompanion.insert(
                id: id,
                canonId: canonId,
                testament: testament,
                orderIndex: orderIndex,
                nameEn: nameEn,
                nameAm: nameAm,
                abbrevEn: abbrevEn,
                abbrevAm: abbrevAm,
                chapters: chapters,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BibleBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BibleBooksTable,
      BibleBookRow,
      $$BibleBooksTableFilterComposer,
      $$BibleBooksTableOrderingComposer,
      $$BibleBooksTableAnnotationComposer,
      $$BibleBooksTableCreateCompanionBuilder,
      $$BibleBooksTableUpdateCompanionBuilder,
      (
        BibleBookRow,
        BaseReferences<_$AppDatabase, $BibleBooksTable, BibleBookRow>,
      ),
      BibleBookRow,
      PrefetchHooks Function()
    >;
typedef $$BibleVersesTableCreateCompanionBuilder =
    BibleVersesCompanion Function({
      required String bookId,
      required int chapter,
      required int verse,
      required String textEn,
      required String textAm,
      Value<int> rowid,
    });
typedef $$BibleVersesTableUpdateCompanionBuilder =
    BibleVersesCompanion Function({
      Value<String> bookId,
      Value<int> chapter,
      Value<int> verse,
      Value<String> textEn,
      Value<String> textAm,
      Value<int> rowid,
    });

class $$BibleVersesTableFilterComposer
    extends Composer<_$AppDatabase, $BibleVersesTable> {
  $$BibleVersesTableFilterComposer({
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

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textEn => $composableBuilder(
    column: $table.textEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textAm => $composableBuilder(
    column: $table.textAm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BibleVersesTableOrderingComposer
    extends Composer<_$AppDatabase, $BibleVersesTable> {
  $$BibleVersesTableOrderingComposer({
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

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textEn => $composableBuilder(
    column: $table.textEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textAm => $composableBuilder(
    column: $table.textAm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BibleVersesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BibleVersesTable> {
  $$BibleVersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get textEn =>
      $composableBuilder(column: $table.textEn, builder: (column) => column);

  GeneratedColumn<String> get textAm =>
      $composableBuilder(column: $table.textAm, builder: (column) => column);
}

class $$BibleVersesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BibleVersesTable,
          BibleVerseRow,
          $$BibleVersesTableFilterComposer,
          $$BibleVersesTableOrderingComposer,
          $$BibleVersesTableAnnotationComposer,
          $$BibleVersesTableCreateCompanionBuilder,
          $$BibleVersesTableUpdateCompanionBuilder,
          (
            BibleVerseRow,
            BaseReferences<_$AppDatabase, $BibleVersesTable, BibleVerseRow>,
          ),
          BibleVerseRow,
          PrefetchHooks Function()
        > {
  $$BibleVersesTableTableManager(_$AppDatabase db, $BibleVersesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BibleVersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BibleVersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BibleVersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verse = const Value.absent(),
                Value<String> textEn = const Value.absent(),
                Value<String> textAm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BibleVersesCompanion(
                bookId: bookId,
                chapter: chapter,
                verse: verse,
                textEn: textEn,
                textAm: textAm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required int chapter,
                required int verse,
                required String textEn,
                required String textAm,
                Value<int> rowid = const Value.absent(),
              }) => BibleVersesCompanion.insert(
                bookId: bookId,
                chapter: chapter,
                verse: verse,
                textEn: textEn,
                textAm: textAm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BibleVersesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BibleVersesTable,
      BibleVerseRow,
      $$BibleVersesTableFilterComposer,
      $$BibleVersesTableOrderingComposer,
      $$BibleVersesTableAnnotationComposer,
      $$BibleVersesTableCreateCompanionBuilder,
      $$BibleVersesTableUpdateCompanionBuilder,
      (
        BibleVerseRow,
        BaseReferences<_$AppDatabase, $BibleVersesTable, BibleVerseRow>,
      ),
      BibleVerseRow,
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
  $$PersonalPrayersTableTableManager get personalPrayers =>
      $$PersonalPrayersTableTableManager(_db, _db.personalPrayers);
  $$BibleBooksTableTableManager get bibleBooks =>
      $$BibleBooksTableTableManager(_db, _db.bibleBooks);
  $$BibleVersesTableTableManager get bibleVerses =>
      $$BibleVersesTableTableManager(_db, _db.bibleVerses);
}
