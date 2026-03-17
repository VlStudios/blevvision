// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $MediaItemsTable extends MediaItems
    with TableInfo<$MediaItemsTable, MediaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
    'tmdb_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
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
  static const VerificationMeta _posterPathMeta = const VerificationMeta(
    'posterPath',
  );
  @override
  late final GeneratedColumn<String> posterPath = GeneratedColumn<String>(
    'poster_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overviewMeta = const VerificationMeta(
    'overview',
  );
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
    'overview',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tmdbId,
    mediaType,
    title,
    posterPath,
    overview,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tmdb_id')) {
      context.handle(
        _tmdbIdMeta,
        tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('poster_path')) {
      context.handle(
        _posterPathMeta,
        posterPath.isAcceptableOrUnknown(data['poster_path']!, _posterPathMeta),
      );
    }
    if (data.containsKey('overview')) {
      context.handle(
        _overviewMeta,
        overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tmdbId, mediaType},
  ];
  @override
  MediaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tmdbId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tmdb_id'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      posterPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_path'],
      ),
      overview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overview'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MediaItemsTable createAlias(String alias) {
    return $MediaItemsTable(attachedDatabase, alias);
  }
}

class MediaItem extends DataClass implements Insertable<MediaItem> {
  final int id;
  final int tmdbId;
  final String mediaType;
  final String title;
  final String? posterPath;
  final String? overview;
  final DateTime createdAt;
  const MediaItem({
    required this.id,
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterPath,
    this.overview,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tmdb_id'] = Variable<int>(tmdbId);
    map['media_type'] = Variable<String>(mediaType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || posterPath != null) {
      map['poster_path'] = Variable<String>(posterPath);
    }
    if (!nullToAbsent || overview != null) {
      map['overview'] = Variable<String>(overview);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MediaItemsCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsCompanion(
      id: Value(id),
      tmdbId: Value(tmdbId),
      mediaType: Value(mediaType),
      title: Value(title),
      posterPath: posterPath == null && nullToAbsent
          ? const Value.absent()
          : Value(posterPath),
      overview: overview == null && nullToAbsent
          ? const Value.absent()
          : Value(overview),
      createdAt: Value(createdAt),
    );
  }

  factory MediaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItem(
      id: serializer.fromJson<int>(json['id']),
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      title: serializer.fromJson<String>(json['title']),
      posterPath: serializer.fromJson<String?>(json['posterPath']),
      overview: serializer.fromJson<String?>(json['overview']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tmdbId': serializer.toJson<int>(tmdbId),
      'mediaType': serializer.toJson<String>(mediaType),
      'title': serializer.toJson<String>(title),
      'posterPath': serializer.toJson<String?>(posterPath),
      'overview': serializer.toJson<String?>(overview),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MediaItem copyWith({
    int? id,
    int? tmdbId,
    String? mediaType,
    String? title,
    Value<String?> posterPath = const Value.absent(),
    Value<String?> overview = const Value.absent(),
    DateTime? createdAt,
  }) => MediaItem(
    id: id ?? this.id,
    tmdbId: tmdbId ?? this.tmdbId,
    mediaType: mediaType ?? this.mediaType,
    title: title ?? this.title,
    posterPath: posterPath.present ? posterPath.value : this.posterPath,
    overview: overview.present ? overview.value : this.overview,
    createdAt: createdAt ?? this.createdAt,
  );
  MediaItem copyWithCompanion(MediaItemsCompanion data) {
    return MediaItem(
      id: data.id.present ? data.id.value : this.id,
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      title: data.title.present ? data.title.value : this.title,
      posterPath: data.posterPath.present
          ? data.posterPath.value
          : this.posterPath,
      overview: data.overview.present ? data.overview.value : this.overview,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItem(')
          ..write('id: $id, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('title: $title, ')
          ..write('posterPath: $posterPath, ')
          ..write('overview: $overview, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tmdbId,
    mediaType,
    title,
    posterPath,
    overview,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItem &&
          other.id == this.id &&
          other.tmdbId == this.tmdbId &&
          other.mediaType == this.mediaType &&
          other.title == this.title &&
          other.posterPath == this.posterPath &&
          other.overview == this.overview &&
          other.createdAt == this.createdAt);
}

class MediaItemsCompanion extends UpdateCompanion<MediaItem> {
  final Value<int> id;
  final Value<int> tmdbId;
  final Value<String> mediaType;
  final Value<String> title;
  final Value<String?> posterPath;
  final Value<String?> overview;
  final Value<DateTime> createdAt;
  const MediaItemsCompanion({
    this.id = const Value.absent(),
    this.tmdbId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.title = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.overview = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MediaItemsCompanion.insert({
    this.id = const Value.absent(),
    required int tmdbId,
    required String mediaType,
    required String title,
    this.posterPath = const Value.absent(),
    this.overview = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : tmdbId = Value(tmdbId),
       mediaType = Value(mediaType),
       title = Value(title);
  static Insertable<MediaItem> custom({
    Expression<int>? id,
    Expression<int>? tmdbId,
    Expression<String>? mediaType,
    Expression<String>? title,
    Expression<String>? posterPath,
    Expression<String>? overview,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (mediaType != null) 'media_type': mediaType,
      if (title != null) 'title': title,
      if (posterPath != null) 'poster_path': posterPath,
      if (overview != null) 'overview': overview,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MediaItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? tmdbId,
    Value<String>? mediaType,
    Value<String>? title,
    Value<String?>? posterPath,
    Value<String?>? overview,
    Value<DateTime>? createdAt,
  }) {
    return MediaItemsCompanion(
      id: id ?? this.id,
      tmdbId: tmdbId ?? this.tmdbId,
      mediaType: mediaType ?? this.mediaType,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      overview: overview ?? this.overview,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (posterPath.present) {
      map['poster_path'] = Variable<String>(posterPath.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsCompanion(')
          ..write('id: $id, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('mediaType: $mediaType, ')
          ..write('title: $title, ')
          ..write('posterPath: $posterPath, ')
          ..write('overview: $overview, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WatchlistTable extends Watchlist
    with TableInfo<$WatchlistTable, WatchlistData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchlistTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id)',
    ),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, mediaId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watchlist';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchlistData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchlistData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchlistData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $WatchlistTable createAlias(String alias) {
    return $WatchlistTable(attachedDatabase, alias);
  }
}

class WatchlistData extends DataClass implements Insertable<WatchlistData> {
  final int id;
  final int mediaId;
  final DateTime addedAt;
  const WatchlistData({
    required this.id,
    required this.mediaId,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['media_id'] = Variable<int>(mediaId);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  WatchlistCompanion toCompanion(bool nullToAbsent) {
    return WatchlistCompanion(
      id: Value(id),
      mediaId: Value(mediaId),
      addedAt: Value(addedAt),
    );
  }

  factory WatchlistData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchlistData(
      id: serializer.fromJson<int>(json['id']),
      mediaId: serializer.fromJson<int>(json['mediaId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mediaId': serializer.toJson<int>(mediaId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  WatchlistData copyWith({int? id, int? mediaId, DateTime? addedAt}) =>
      WatchlistData(
        id: id ?? this.id,
        mediaId: mediaId ?? this.mediaId,
        addedAt: addedAt ?? this.addedAt,
      );
  WatchlistData copyWithCompanion(WatchlistCompanion data) {
    return WatchlistData(
      id: data.id.present ? data.id.value : this.id,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistData(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mediaId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchlistData &&
          other.id == this.id &&
          other.mediaId == this.mediaId &&
          other.addedAt == this.addedAt);
}

class WatchlistCompanion extends UpdateCompanion<WatchlistData> {
  final Value<int> id;
  final Value<int> mediaId;
  final Value<DateTime> addedAt;
  const WatchlistCompanion({
    this.id = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  WatchlistCompanion.insert({
    this.id = const Value.absent(),
    required int mediaId,
    this.addedAt = const Value.absent(),
  }) : mediaId = Value(mediaId);
  static Insertable<WatchlistData> custom({
    Expression<int>? id,
    Expression<int>? mediaId,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaId != null) 'media_id': mediaId,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  WatchlistCompanion copyWith({
    Value<int>? id,
    Value<int>? mediaId,
    Value<DateTime>? addedAt,
  }) {
    return WatchlistCompanion(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<int>(mediaId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistCompanion(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $ProgressTable extends Progress
    with TableInfo<$ProgressTable, ProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id)',
    ),
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
    'season',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeMeta = const VerificationMeta(
    'episode',
  );
  @override
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
    'episode',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionSecMeta = const VerificationMeta(
    'positionSec',
  );
  @override
  late final GeneratedColumn<int> positionSec = GeneratedColumn<int>(
    'position_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaId,
    season,
    episode,
    positionSec,
    completed,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    }
    if (data.containsKey('episode')) {
      context.handle(
        _episodeMeta,
        episode.isAcceptableOrUnknown(data['episode']!, _episodeMeta),
      );
    }
    if (data.containsKey('position_sec')) {
      context.handle(
        _positionSecMeta,
        positionSec.isAcceptableOrUnknown(
          data['position_sec']!,
          _positionSecMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_id'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season'],
      ),
      episode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode'],
      ),
      positionSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_sec'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProgressTable createAlias(String alias) {
    return $ProgressTable(attachedDatabase, alias);
  }
}

class ProgressData extends DataClass implements Insertable<ProgressData> {
  final int id;
  final int mediaId;
  final int? season;
  final int? episode;
  final int positionSec;
  final bool completed;
  final DateTime updatedAt;
  const ProgressData({
    required this.id,
    required this.mediaId,
    this.season,
    this.episode,
    required this.positionSec,
    required this.completed,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['media_id'] = Variable<int>(mediaId);
    if (!nullToAbsent || season != null) {
      map['season'] = Variable<int>(season);
    }
    if (!nullToAbsent || episode != null) {
      map['episode'] = Variable<int>(episode);
    }
    map['position_sec'] = Variable<int>(positionSec);
    map['completed'] = Variable<bool>(completed);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProgressCompanion toCompanion(bool nullToAbsent) {
    return ProgressCompanion(
      id: Value(id),
      mediaId: Value(mediaId),
      season: season == null && nullToAbsent
          ? const Value.absent()
          : Value(season),
      episode: episode == null && nullToAbsent
          ? const Value.absent()
          : Value(episode),
      positionSec: Value(positionSec),
      completed: Value(completed),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressData(
      id: serializer.fromJson<int>(json['id']),
      mediaId: serializer.fromJson<int>(json['mediaId']),
      season: serializer.fromJson<int?>(json['season']),
      episode: serializer.fromJson<int?>(json['episode']),
      positionSec: serializer.fromJson<int>(json['positionSec']),
      completed: serializer.fromJson<bool>(json['completed']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mediaId': serializer.toJson<int>(mediaId),
      'season': serializer.toJson<int?>(season),
      'episode': serializer.toJson<int?>(episode),
      'positionSec': serializer.toJson<int>(positionSec),
      'completed': serializer.toJson<bool>(completed),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProgressData copyWith({
    int? id,
    int? mediaId,
    Value<int?> season = const Value.absent(),
    Value<int?> episode = const Value.absent(),
    int? positionSec,
    bool? completed,
    DateTime? updatedAt,
  }) => ProgressData(
    id: id ?? this.id,
    mediaId: mediaId ?? this.mediaId,
    season: season.present ? season.value : this.season,
    episode: episode.present ? episode.value : this.episode,
    positionSec: positionSec ?? this.positionSec,
    completed: completed ?? this.completed,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProgressData copyWithCompanion(ProgressCompanion data) {
    return ProgressData(
      id: data.id.present ? data.id.value : this.id,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      season: data.season.present ? data.season.value : this.season,
      episode: data.episode.present ? data.episode.value : this.episode,
      positionSec: data.positionSec.present
          ? data.positionSec.value
          : this.positionSec,
      completed: data.completed.present ? data.completed.value : this.completed,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressData(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('positionSec: $positionSec, ')
          ..write('completed: $completed, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mediaId,
    season,
    episode,
    positionSec,
    completed,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressData &&
          other.id == this.id &&
          other.mediaId == this.mediaId &&
          other.season == this.season &&
          other.episode == this.episode &&
          other.positionSec == this.positionSec &&
          other.completed == this.completed &&
          other.updatedAt == this.updatedAt);
}

class ProgressCompanion extends UpdateCompanion<ProgressData> {
  final Value<int> id;
  final Value<int> mediaId;
  final Value<int?> season;
  final Value<int?> episode;
  final Value<int> positionSec;
  final Value<bool> completed;
  final Value<DateTime> updatedAt;
  const ProgressCompanion({
    this.id = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    this.positionSec = const Value.absent(),
    this.completed = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProgressCompanion.insert({
    this.id = const Value.absent(),
    required int mediaId,
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    this.positionSec = const Value.absent(),
    this.completed = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : mediaId = Value(mediaId);
  static Insertable<ProgressData> custom({
    Expression<int>? id,
    Expression<int>? mediaId,
    Expression<int>? season,
    Expression<int>? episode,
    Expression<int>? positionSec,
    Expression<bool>? completed,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaId != null) 'media_id': mediaId,
      if (season != null) 'season': season,
      if (episode != null) 'episode': episode,
      if (positionSec != null) 'position_sec': positionSec,
      if (completed != null) 'completed': completed,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? mediaId,
    Value<int?>? season,
    Value<int?>? episode,
    Value<int>? positionSec,
    Value<bool>? completed,
    Value<DateTime>? updatedAt,
  }) {
    return ProgressCompanion(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      positionSec: positionSec ?? this.positionSec,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<int>(mediaId.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (episode.present) {
      map['episode'] = Variable<int>(episode.value);
    }
    if (positionSec.present) {
      map['position_sec'] = Variable<int>(positionSec.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressCompanion(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('positionSec: $positionSec, ')
          ..write('completed: $completed, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScheduleItemsTable extends ScheduleItems
    with TableInfo<$ScheduleItemsTable, ScheduleItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id)',
    ),
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
    'season',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeMeta = const VerificationMeta(
    'episode',
  );
  @override
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
    'episode',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedAtMeta = const VerificationMeta(
    'plannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> plannedAt = GeneratedColumn<DateTime>(
    'planned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaId,
    season,
    episode,
    plannedAt,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    }
    if (data.containsKey('episode')) {
      context.handle(
        _episodeMeta,
        episode.isAcceptableOrUnknown(data['episode']!, _episodeMeta),
      );
    }
    if (data.containsKey('planned_at')) {
      context.handle(
        _plannedAtMeta,
        plannedAt.isAcceptableOrUnknown(data['planned_at']!, _plannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_plannedAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_id'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season'],
      ),
      episode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode'],
      ),
      plannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ScheduleItemsTable createAlias(String alias) {
    return $ScheduleItemsTable(attachedDatabase, alias);
  }
}

class ScheduleItem extends DataClass implements Insertable<ScheduleItem> {
  final int id;
  final int mediaId;
  final int? season;
  final int? episode;
  final DateTime plannedAt;
  final String? note;
  final DateTime createdAt;
  const ScheduleItem({
    required this.id,
    required this.mediaId,
    this.season,
    this.episode,
    required this.plannedAt,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['media_id'] = Variable<int>(mediaId);
    if (!nullToAbsent || season != null) {
      map['season'] = Variable<int>(season);
    }
    if (!nullToAbsent || episode != null) {
      map['episode'] = Variable<int>(episode);
    }
    map['planned_at'] = Variable<DateTime>(plannedAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScheduleItemsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleItemsCompanion(
      id: Value(id),
      mediaId: Value(mediaId),
      season: season == null && nullToAbsent
          ? const Value.absent()
          : Value(season),
      episode: episode == null && nullToAbsent
          ? const Value.absent()
          : Value(episode),
      plannedAt: Value(plannedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory ScheduleItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleItem(
      id: serializer.fromJson<int>(json['id']),
      mediaId: serializer.fromJson<int>(json['mediaId']),
      season: serializer.fromJson<int?>(json['season']),
      episode: serializer.fromJson<int?>(json['episode']),
      plannedAt: serializer.fromJson<DateTime>(json['plannedAt']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mediaId': serializer.toJson<int>(mediaId),
      'season': serializer.toJson<int?>(season),
      'episode': serializer.toJson<int?>(episode),
      'plannedAt': serializer.toJson<DateTime>(plannedAt),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScheduleItem copyWith({
    int? id,
    int? mediaId,
    Value<int?> season = const Value.absent(),
    Value<int?> episode = const Value.absent(),
    DateTime? plannedAt,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => ScheduleItem(
    id: id ?? this.id,
    mediaId: mediaId ?? this.mediaId,
    season: season.present ? season.value : this.season,
    episode: episode.present ? episode.value : this.episode,
    plannedAt: plannedAt ?? this.plannedAt,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  ScheduleItem copyWithCompanion(ScheduleItemsCompanion data) {
    return ScheduleItem(
      id: data.id.present ? data.id.value : this.id,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      season: data.season.present ? data.season.value : this.season,
      episode: data.episode.present ? data.episode.value : this.episode,
      plannedAt: data.plannedAt.present ? data.plannedAt.value : this.plannedAt,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleItem(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mediaId, season, episode, plannedAt, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleItem &&
          other.id == this.id &&
          other.mediaId == this.mediaId &&
          other.season == this.season &&
          other.episode == this.episode &&
          other.plannedAt == this.plannedAt &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class ScheduleItemsCompanion extends UpdateCompanion<ScheduleItem> {
  final Value<int> id;
  final Value<int> mediaId;
  final Value<int?> season;
  final Value<int?> episode;
  final Value<DateTime> plannedAt;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const ScheduleItemsCompanion({
    this.id = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    this.plannedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ScheduleItemsCompanion.insert({
    this.id = const Value.absent(),
    required int mediaId,
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    required DateTime plannedAt,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : mediaId = Value(mediaId),
       plannedAt = Value(plannedAt);
  static Insertable<ScheduleItem> custom({
    Expression<int>? id,
    Expression<int>? mediaId,
    Expression<int>? season,
    Expression<int>? episode,
    Expression<DateTime>? plannedAt,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaId != null) 'media_id': mediaId,
      if (season != null) 'season': season,
      if (episode != null) 'episode': episode,
      if (plannedAt != null) 'planned_at': plannedAt,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ScheduleItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? mediaId,
    Value<int?>? season,
    Value<int?>? episode,
    Value<DateTime>? plannedAt,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return ScheduleItemsCompanion(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      plannedAt: plannedAt ?? this.plannedAt,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<int>(mediaId.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (episode.present) {
      map['episode'] = Variable<int>(episode.value);
    }
    if (plannedAt.present) {
      map['planned_at'] = Variable<DateTime>(plannedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleItemsCompanion(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MediaItemsTable mediaItems = $MediaItemsTable(this);
  late final $WatchlistTable watchlist = $WatchlistTable(this);
  late final $ProgressTable progress = $ProgressTable(this);
  late final $ScheduleItemsTable scheduleItems = $ScheduleItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mediaItems,
    watchlist,
    progress,
    scheduleItems,
  ];
}

typedef $$MediaItemsTableCreateCompanionBuilder =
    MediaItemsCompanion Function({
      Value<int> id,
      required int tmdbId,
      required String mediaType,
      required String title,
      Value<String?> posterPath,
      Value<String?> overview,
      Value<DateTime> createdAt,
    });
typedef $$MediaItemsTableUpdateCompanionBuilder =
    MediaItemsCompanion Function({
      Value<int> id,
      Value<int> tmdbId,
      Value<String> mediaType,
      Value<String> title,
      Value<String?> posterPath,
      Value<String?> overview,
      Value<DateTime> createdAt,
    });

final class $$MediaItemsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem> {
  $$MediaItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WatchlistTable, List<WatchlistData>>
  _watchlistRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.watchlist,
    aliasName: $_aliasNameGenerator(db.mediaItems.id, db.watchlist.mediaId),
  );

  $$WatchlistTableProcessedTableManager get watchlistRefs {
    final manager = $$WatchlistTableTableManager(
      $_db,
      $_db.watchlist,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_watchlistRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProgressTable, List<ProgressData>>
  _progressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.progress,
    aliasName: $_aliasNameGenerator(db.mediaItems.id, db.progress.mediaId),
  );

  $$ProgressTableProcessedTableManager get progressRefs {
    final manager = $$ProgressTableTableManager(
      $_db,
      $_db.progress,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_progressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScheduleItemsTable, List<ScheduleItem>>
  _scheduleItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scheduleItems,
    aliasName: $_aliasNameGenerator(db.mediaItems.id, db.scheduleItems.mediaId),
  );

  $$ScheduleItemsTableProcessedTableManager get scheduleItemsRefs {
    final manager = $$ScheduleItemsTableTableManager(
      $_db,
      $_db.scheduleItems,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scheduleItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableFilterComposer({
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

  ColumnFilters<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> watchlistRefs(
    Expression<bool> Function($$WatchlistTableFilterComposer f) f,
  ) {
    final $$WatchlistTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchlist,
      getReferencedColumn: (t) => t.mediaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchlistTableFilterComposer(
            $db: $db,
            $table: $db.watchlist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> progressRefs(
    Expression<bool> Function($$ProgressTableFilterComposer f) f,
  ) {
    final $$ProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.progress,
      getReferencedColumn: (t) => t.mediaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgressTableFilterComposer(
            $db: $db,
            $table: $db.progress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scheduleItemsRefs(
    Expression<bool> Function($$ScheduleItemsTableFilterComposer f) f,
  ) {
    final $$ScheduleItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleItems,
      getReferencedColumn: (t) => t.mediaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleItemsTableFilterComposer(
            $db: $db,
            $table: $db.scheduleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableOrderingComposer({
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

  ColumnOrderings<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> watchlistRefs<T extends Object>(
    Expression<T> Function($$WatchlistTableAnnotationComposer a) f,
  ) {
    final $$WatchlistTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchlist,
      getReferencedColumn: (t) => t.mediaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchlistTableAnnotationComposer(
            $db: $db,
            $table: $db.watchlist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> progressRefs<T extends Object>(
    Expression<T> Function($$ProgressTableAnnotationComposer a) f,
  ) {
    final $$ProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.progress,
      getReferencedColumn: (t) => t.mediaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.progress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scheduleItemsRefs<T extends Object>(
    Expression<T> Function($$ScheduleItemsTableAnnotationComposer a) f,
  ) {
    final $$ScheduleItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleItems,
      getReferencedColumn: (t) => t.mediaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.scheduleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaItemsTable,
          MediaItem,
          $$MediaItemsTableFilterComposer,
          $$MediaItemsTableOrderingComposer,
          $$MediaItemsTableAnnotationComposer,
          $$MediaItemsTableCreateCompanionBuilder,
          $$MediaItemsTableUpdateCompanionBuilder,
          (MediaItem, $$MediaItemsTableReferences),
          MediaItem,
          PrefetchHooks Function({
            bool watchlistRefs,
            bool progressRefs,
            bool scheduleItemsRefs,
          })
        > {
  $$MediaItemsTableTableManager(_$AppDatabase db, $MediaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> tmdbId = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MediaItemsCompanion(
                id: id,
                tmdbId: tmdbId,
                mediaType: mediaType,
                title: title,
                posterPath: posterPath,
                overview: overview,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int tmdbId,
                required String mediaType,
                required String title,
                Value<String?> posterPath = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MediaItemsCompanion.insert(
                id: id,
                tmdbId: tmdbId,
                mediaType: mediaType,
                title: title,
                posterPath: posterPath,
                overview: overview,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MediaItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                watchlistRefs = false,
                progressRefs = false,
                scheduleItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (watchlistRefs) db.watchlist,
                    if (progressRefs) db.progress,
                    if (scheduleItemsRefs) db.scheduleItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (watchlistRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          WatchlistData
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._watchlistRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).watchlistRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (progressRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          ProgressData
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._progressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).progressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scheduleItemsRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          ScheduleItem
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._scheduleItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduleItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MediaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaItemsTable,
      MediaItem,
      $$MediaItemsTableFilterComposer,
      $$MediaItemsTableOrderingComposer,
      $$MediaItemsTableAnnotationComposer,
      $$MediaItemsTableCreateCompanionBuilder,
      $$MediaItemsTableUpdateCompanionBuilder,
      (MediaItem, $$MediaItemsTableReferences),
      MediaItem,
      PrefetchHooks Function({
        bool watchlistRefs,
        bool progressRefs,
        bool scheduleItemsRefs,
      })
    >;
typedef $$WatchlistTableCreateCompanionBuilder =
    WatchlistCompanion Function({
      Value<int> id,
      required int mediaId,
      Value<DateTime> addedAt,
    });
typedef $$WatchlistTableUpdateCompanionBuilder =
    WatchlistCompanion Function({
      Value<int> id,
      Value<int> mediaId,
      Value<DateTime> addedAt,
    });

final class $$WatchlistTableReferences
    extends BaseReferences<_$AppDatabase, $WatchlistTable, WatchlistData> {
  $$WatchlistTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MediaItemsTable _mediaIdTable(_$AppDatabase db) =>
      db.mediaItems.createAlias(
        $_aliasNameGenerator(db.watchlist.mediaId, db.mediaItems.id),
      );

  $$MediaItemsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<int>('media_id')!;

    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WatchlistTableFilterComposer
    extends Composer<_$AppDatabase, $WatchlistTable> {
  $$WatchlistTableFilterComposer({
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

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MediaItemsTableFilterComposer get mediaId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchlistTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchlistTable> {
  $$WatchlistTableOrderingComposer({
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

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableOrderingComposer get mediaId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchlistTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchlistTable> {
  $$WatchlistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$MediaItemsTableAnnotationComposer get mediaId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchlistTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchlistTable,
          WatchlistData,
          $$WatchlistTableFilterComposer,
          $$WatchlistTableOrderingComposer,
          $$WatchlistTableAnnotationComposer,
          $$WatchlistTableCreateCompanionBuilder,
          $$WatchlistTableUpdateCompanionBuilder,
          (WatchlistData, $$WatchlistTableReferences),
          WatchlistData,
          PrefetchHooks Function({bool mediaId})
        > {
  $$WatchlistTableTableManager(_$AppDatabase db, $WatchlistTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchlistTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchlistTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchlistTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mediaId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => WatchlistCompanion(
                id: id,
                mediaId: mediaId,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mediaId,
                Value<DateTime> addedAt = const Value.absent(),
              }) => WatchlistCompanion.insert(
                id: id,
                mediaId: mediaId,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WatchlistTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false}) {
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
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable: $$WatchlistTableReferences
                                    ._mediaIdTable(db),
                                referencedColumn: $$WatchlistTableReferences
                                    ._mediaIdTable(db)
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

typedef $$WatchlistTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchlistTable,
      WatchlistData,
      $$WatchlistTableFilterComposer,
      $$WatchlistTableOrderingComposer,
      $$WatchlistTableAnnotationComposer,
      $$WatchlistTableCreateCompanionBuilder,
      $$WatchlistTableUpdateCompanionBuilder,
      (WatchlistData, $$WatchlistTableReferences),
      WatchlistData,
      PrefetchHooks Function({bool mediaId})
    >;
typedef $$ProgressTableCreateCompanionBuilder =
    ProgressCompanion Function({
      Value<int> id,
      required int mediaId,
      Value<int?> season,
      Value<int?> episode,
      Value<int> positionSec,
      Value<bool> completed,
      Value<DateTime> updatedAt,
    });
typedef $$ProgressTableUpdateCompanionBuilder =
    ProgressCompanion Function({
      Value<int> id,
      Value<int> mediaId,
      Value<int?> season,
      Value<int?> episode,
      Value<int> positionSec,
      Value<bool> completed,
      Value<DateTime> updatedAt,
    });

final class $$ProgressTableReferences
    extends BaseReferences<_$AppDatabase, $ProgressTable, ProgressData> {
  $$ProgressTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MediaItemsTable _mediaIdTable(_$AppDatabase db) => db.mediaItems
      .createAlias($_aliasNameGenerator(db.progress.mediaId, db.mediaItems.id));

  $$MediaItemsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<int>('media_id')!;

    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableFilterComposer({
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

  ColumnFilters<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionSec => $composableBuilder(
    column: $table.positionSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MediaItemsTableFilterComposer get mediaId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableOrderingComposer({
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

  ColumnOrderings<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionSec => $composableBuilder(
    column: $table.positionSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableOrderingComposer get mediaId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get episode =>
      $composableBuilder(column: $table.episode, builder: (column) => column);

  GeneratedColumn<int> get positionSec => $composableBuilder(
    column: $table.positionSec,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MediaItemsTableAnnotationComposer get mediaId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressTable,
          ProgressData,
          $$ProgressTableFilterComposer,
          $$ProgressTableOrderingComposer,
          $$ProgressTableAnnotationComposer,
          $$ProgressTableCreateCompanionBuilder,
          $$ProgressTableUpdateCompanionBuilder,
          (ProgressData, $$ProgressTableReferences),
          ProgressData,
          PrefetchHooks Function({bool mediaId})
        > {
  $$ProgressTableTableManager(_$AppDatabase db, $ProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mediaId = const Value.absent(),
                Value<int?> season = const Value.absent(),
                Value<int?> episode = const Value.absent(),
                Value<int> positionSec = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProgressCompanion(
                id: id,
                mediaId: mediaId,
                season: season,
                episode: episode,
                positionSec: positionSec,
                completed: completed,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mediaId,
                Value<int?> season = const Value.absent(),
                Value<int?> episode = const Value.absent(),
                Value<int> positionSec = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProgressCompanion.insert(
                id: id,
                mediaId: mediaId,
                season: season,
                episode: episode,
                positionSec: positionSec,
                completed: completed,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false}) {
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
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable: $$ProgressTableReferences
                                    ._mediaIdTable(db),
                                referencedColumn: $$ProgressTableReferences
                                    ._mediaIdTable(db)
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

typedef $$ProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressTable,
      ProgressData,
      $$ProgressTableFilterComposer,
      $$ProgressTableOrderingComposer,
      $$ProgressTableAnnotationComposer,
      $$ProgressTableCreateCompanionBuilder,
      $$ProgressTableUpdateCompanionBuilder,
      (ProgressData, $$ProgressTableReferences),
      ProgressData,
      PrefetchHooks Function({bool mediaId})
    >;
typedef $$ScheduleItemsTableCreateCompanionBuilder =
    ScheduleItemsCompanion Function({
      Value<int> id,
      required int mediaId,
      Value<int?> season,
      Value<int?> episode,
      required DateTime plannedAt,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$ScheduleItemsTableUpdateCompanionBuilder =
    ScheduleItemsCompanion Function({
      Value<int> id,
      Value<int> mediaId,
      Value<int?> season,
      Value<int?> episode,
      Value<DateTime> plannedAt,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$ScheduleItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ScheduleItemsTable, ScheduleItem> {
  $$ScheduleItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MediaItemsTable _mediaIdTable(_$AppDatabase db) =>
      db.mediaItems.createAlias(
        $_aliasNameGenerator(db.scheduleItems.mediaId, db.mediaItems.id),
      );

  $$MediaItemsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<int>('media_id')!;

    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScheduleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleItemsTable> {
  $$ScheduleItemsTableFilterComposer({
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

  ColumnFilters<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MediaItemsTableFilterComposer get mediaId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleItemsTable> {
  $$ScheduleItemsTableOrderingComposer({
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

  ColumnOrderings<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableOrderingComposer get mediaId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleItemsTable> {
  $$ScheduleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get episode =>
      $composableBuilder(column: $table.episode, builder: (column) => column);

  GeneratedColumn<DateTime> get plannedAt =>
      $composableBuilder(column: $table.plannedAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MediaItemsTableAnnotationComposer get mediaId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleItemsTable,
          ScheduleItem,
          $$ScheduleItemsTableFilterComposer,
          $$ScheduleItemsTableOrderingComposer,
          $$ScheduleItemsTableAnnotationComposer,
          $$ScheduleItemsTableCreateCompanionBuilder,
          $$ScheduleItemsTableUpdateCompanionBuilder,
          (ScheduleItem, $$ScheduleItemsTableReferences),
          ScheduleItem,
          PrefetchHooks Function({bool mediaId})
        > {
  $$ScheduleItemsTableTableManager(_$AppDatabase db, $ScheduleItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mediaId = const Value.absent(),
                Value<int?> season = const Value.absent(),
                Value<int?> episode = const Value.absent(),
                Value<DateTime> plannedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScheduleItemsCompanion(
                id: id,
                mediaId: mediaId,
                season: season,
                episode: episode,
                plannedAt: plannedAt,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mediaId,
                Value<int?> season = const Value.absent(),
                Value<int?> episode = const Value.absent(),
                required DateTime plannedAt,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScheduleItemsCompanion.insert(
                id: id,
                mediaId: mediaId,
                season: season,
                episode: episode,
                plannedAt: plannedAt,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScheduleItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false}) {
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
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable: $$ScheduleItemsTableReferences
                                    ._mediaIdTable(db),
                                referencedColumn: $$ScheduleItemsTableReferences
                                    ._mediaIdTable(db)
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

typedef $$ScheduleItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleItemsTable,
      ScheduleItem,
      $$ScheduleItemsTableFilterComposer,
      $$ScheduleItemsTableOrderingComposer,
      $$ScheduleItemsTableAnnotationComposer,
      $$ScheduleItemsTableCreateCompanionBuilder,
      $$ScheduleItemsTableUpdateCompanionBuilder,
      (ScheduleItem, $$ScheduleItemsTableReferences),
      ScheduleItem,
      PrefetchHooks Function({bool mediaId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db, _db.mediaItems);
  $$WatchlistTableTableManager get watchlist =>
      $$WatchlistTableTableManager(_db, _db.watchlist);
  $$ProgressTableTableManager get progress =>
      $$ProgressTableTableManager(_db, _db.progress);
  $$ScheduleItemsTableTableManager get scheduleItems =>
      $$ScheduleItemsTableTableManager(_db, _db.scheduleItems);
}
