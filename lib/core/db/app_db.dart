import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

class MediaItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tmdbId => integer()();
  TextColumn get mediaType => text()(); // 'movie' | 'tv'
  TextColumn get title => text()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get overview => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    { tmdbId, mediaType }, // tmdbId + mediaType devem ser únicos em conjunto
  ];
}


class Watchlist extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mediaId => integer().references(MediaItems, #id)();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
}

class Progress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mediaId => integer().references(MediaItems, #id)();
  IntColumn get season => integer().nullable()();
  IntColumn get episode => integer().nullable()();
  IntColumn get positionSec => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  List<String> get customConstraints => ['UNIQUE(media_id, season, episode)'];
}

class ScheduleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mediaId => integer().references(MediaItems, #id)();
  IntColumn get season => integer().nullable()();
  IntColumn get episode => integer().nullable()();
  DateTimeColumn get plannedAt => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [MediaItems, Watchlist, Progress, ScheduleItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase._(QueryExecutor e) : super(e);
  static AppDatabase? _i;
  static AppDatabase get instance => _i ??= AppDatabase._(_open());

  Future<void> ensureOpen() async => customSelect('SELECT 1').get();

  Future<void> clearAllUserData() async {
    await transaction(() async {
      await delete(watchlist).go();
      await delete(scheduleItems).go();
      await delete(progress).go();
      await delete(mediaItems).go();
    });
  }

  @override int get schemaVersion => 1;
}

LazyDatabase _open() => LazyDatabase(() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'blevvision.db'));
  return NativeDatabase.createInBackground(file);
});
