// lib/core/db/watchlist_service.dart
import 'package:drift/drift.dart';
import 'app_db.dart';

typedef WatchlistRow = (WatchlistData, MediaItem);

/// Serviço simples para lidar com Watchlist usando Drift.
class WatchlistService {
  WatchlistService._();
  static final instance = WatchlistService._();
  final _db = AppDatabase.instance;

  /// Observa a Watchlist juntando com MediaItems para renderizar título/poster.
  Stream<List<WatchlistRow>> watchWatchlist() {
    final query = (_db.select(_db.watchlist)
          ..orderBy([(w) => OrderingTerm.desc(w.addedAt)]))
        .join([
      innerJoin(_db.mediaItems, _db.mediaItems.id.equalsExp(_db.watchlist.mediaId)),
    ]);

    return query.watch().map((rows) {
      return rows
          .map<WatchlistRow>(
            (r) => (r.readTable(_db.watchlist), r.readTable(_db.mediaItems)),
          )
          .toList();
    });
  }

  Future<bool> isInWatchlist({
    required int tmdbId,
    required String mediaType,
  }) async {
    final media = await (_db.select(_db.mediaItems)
          ..where((m) => m.tmdbId.equals(tmdbId) & m.mediaType.equals(mediaType)))
        .getSingleOrNull();
    if (media == null) return false;

    final w = await (_db.select(_db.watchlist)
          ..where((w) => w.mediaId.equals(media.id)))
        .getSingleOrNull();
    return w != null;
  }

  /// Adiciona (ou reaproveita) MediaItem e cria entrada na Watchlist
  Future<void> addToWatchlist({
    required int tmdbId,
    required String mediaType,
    required String title,
    String? posterPath,
    String? overview,
  }) async {
    // 1) tenta achar media
    final existing = await (_db.select(_db.mediaItems)
          ..where((m) => m.tmdbId.equals(tmdbId) & m.mediaType.equals(mediaType)))
        .getSingleOrNull();

    // 2) garante mediaId com upsert
    int mediaId;
    if (existing != null) {
      mediaId = existing.id;
    } else {
      final insertedId = await _db.into(_db.mediaItems).insert(
            MediaItemsCompanion.insert(
              tmdbId: tmdbId,
              mediaType: mediaType,
              title: title,
              posterPath: Value(posterPath),
              overview: Value(overview),
            ),
            mode: InsertMode.insertOrIgnore, // respeita unique (tmdbId+mediaType)
          );

      if (insertedId != 0) {
        mediaId = insertedId;
      } else {
        // conflito de unique -> busca id existente
        final again = await (_db.select(_db.mediaItems)
              ..where((m) => m.tmdbId.equals(tmdbId) & m.mediaType.equals(mediaType)))
            .getSingle();
        mediaId = again.id; // <-- faltava isso
      }
    }

    // 3) evita duplicado na watchlist
    final existsWatch = await (_db.select(_db.watchlist)
          ..where((w) => w.mediaId.equals(mediaId)))
        .getSingleOrNull();

    if (existsWatch == null) {
      await _db.into(_db.watchlist).insert(
            WatchlistCompanion.insert(mediaId: mediaId),
          );
    }
  }

  Future<void> removeFromWatchlist({
    required int tmdbId,
    required String mediaType,
  }) async {
    final media = await (_db.select(_db.mediaItems)
          ..where((m) => m.tmdbId.equals(tmdbId) & m.mediaType.equals(mediaType)))
        .getSingleOrNull();
    if (media == null) return;

    await (_db.delete(_db.watchlist)..where((w) => w.mediaId.equals(media.id))).go();
  }

  /// Conveniência: alterna presença na watchlist.
  Future<void> toggleWatchlist({
    required int tmdbId,
    required String mediaType,
    required String title,
    String? posterPath,
    String? overview,
  }) async {
    final inList = await isInWatchlist(tmdbId: tmdbId, mediaType: mediaType);
    if (inList) {
      await removeFromWatchlist(tmdbId: tmdbId, mediaType: mediaType);
    } else {
      await addToWatchlist(
        tmdbId: tmdbId,
        mediaType: mediaType,
        title: title,
        posterPath: posterPath,
        overview: overview,
      );
    }
  }
}
