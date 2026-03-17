import 'package:drift/drift.dart';
import 'app_db.dart';

class ScheduleService {
  ScheduleService._();
  static final instance = ScheduleService._();
  final _db = AppDatabase.instance;

  /// Lista os agendamentos (com join em MediaItems) ordenados por data.
  Stream<List<(ScheduleItem, MediaItem)>> watchUpcoming() {
    final q = (_db.select(_db.scheduleItems)
          ..orderBy([(s) => OrderingTerm.asc(s.plannedAt)]))
        .join([
      innerJoin(_db.mediaItems, _db.mediaItems.id.equalsExp(_db.scheduleItems.mediaId)),
    ]);

    return q.watch().map((rows) {
      return rows
          .map<(ScheduleItem, MediaItem)>(
            (r) => (r.readTable(_db.scheduleItems), r.readTable(_db.mediaItems)),
          )
          .toList();
    });
  }

  /// Cria (ou reutiliza) um MediaItem e agenda apenas um item.
  Future<void> addSchedule({
    required int tmdbId,
    required String mediaType,
    required String title,
    String? posterPath,
    String? overview,
    required DateTime plannedAt,
    String? note,
    int? season,
    int? episode,
    int episodesCount = 1,
  }) async {
    final existing = await (_db.select(_db.mediaItems)
          ..where((m) => m.tmdbId.equals(tmdbId) & m.mediaType.equals(mediaType)))
        .getSingleOrNull();

    final mediaId = existing != null
        ? existing.id
        : await _db.into(_db.mediaItems).insert(
              MediaItemsCompanion.insert(
                tmdbId: tmdbId,
                mediaType: mediaType,
                title: title,
                posterPath: Value(posterPath),
                overview: Value(overview),
              ),
              mode: InsertMode.insertOrIgnore,
            );

    await _db.into(_db.scheduleItems).insert(
          ScheduleItemsCompanion.insert(
            mediaId: existing?.id ?? mediaId,
            plannedAt: plannedAt,
            season: Value(season),
            episode: Value(episode),
            note: Value(note),
          ),
        );
  }

  Future<void> removeSchedule(int scheduleId) async {
    await (_db.delete(_db.scheduleItems)..where((s) => s.id.equals(scheduleId))).go();
  }

  Stream<ProgressData?> watchLatestProgressForMedia(int mediaId) {
    final q = _db.select(_db.progress)
      ..where((p) => p.mediaId.equals(mediaId))
      ..orderBy([(p) => OrderingTerm.desc(p.updatedAt), (p) => OrderingTerm.desc(p.id)])
      ..limit(1);
    return q.watchSingleOrNull();
  }

  Future<void> upsertProgress({
    required int mediaId,
    int? season,
    int? episode,
    required int positionSec,
    bool completed = false,
  }) async {
    final sec = positionSec < 0 ? 0 : positionSec;
    final allForMedia = await (_db.select(_db.progress)
          ..where((p) => p.mediaId.equals(mediaId))
          ..orderBy([(p) => OrderingTerm.desc(p.updatedAt), (p) => OrderingTerm.desc(p.id)]))
        .get();

    final matches = allForMedia
        .where((p) => p.season == season && p.episode == episode)
        .toList();

    final existing = matches.isEmpty ? null : matches.first;

    if (existing == null) {
      await _db.into(_db.progress).insert(
            ProgressCompanion.insert(
              mediaId: mediaId,
              season: Value(season),
              episode: Value(episode),
              positionSec: Value(sec),
              completed: Value(completed),
              updatedAt: Value(DateTime.now()),
            ),
          );
      return;
    }

    await (_db.update(_db.progress)..where((p) => p.id.equals(existing.id))).write(
      ProgressCompanion(
        positionSec: Value(sec),
        completed: Value(completed),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (matches.length > 1) {
      final duplicateIds = matches.skip(1).map((p) => p.id).toList();
      await (_db.delete(_db.progress)..where((p) => p.id.isIn(duplicateIds))).go();
    }
  }

  Future<void> updateScheduleDate({
    required int scheduleId,
    required DateTime dateOnly,
  }) async {
    final normalized = DateTime(dateOnly.year, dateOnly.month, dateOnly.day, 12, 0);
    await (_db.update(_db.scheduleItems)..where((s) => s.id.equals(scheduleId))).write(
      ScheduleItemsCompanion(plannedAt: Value(normalized)),
    );
  }

  Future<void> updateSchedule({
    required int scheduleId,
    required DateTime dateOnly,
    int? season,
    int? episode,
    String? note,
  }) async {
    final normalized = DateTime(dateOnly.year, dateOnly.month, dateOnly.day, 12, 0);
    await (_db.update(_db.scheduleItems)..where((s) => s.id.equals(scheduleId))).write(
      ScheduleItemsCompanion(
        plannedAt: Value(normalized),
        season: Value(season),
        episode: Value(episode),
        note: Value(note),
      ),
    );
  }
}
