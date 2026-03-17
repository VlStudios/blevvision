import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drift/drift.dart';
import '../db/app_db.dart';
import '../db/watchlist_service.dart';
import '../db/schedule_service.dart';

class FirestoreSync {
  FirestoreSync._();
  static final instance = FirestoreSync._();

  FirebaseFirestore get _fs => FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _wl =>
      _fs.collection('users').doc(_uid).collection('watchlist');
  CollectionReference<Map<String, dynamic>> get _sch =>
      _fs.collection('users').doc(_uid).collection('schedule');

  /// PULL inicial: baixa tudo do Firestore e persiste no Drift.
  Future<void> initialPull() async {
    final wlSnap = await _wl.get();
    for (final d in wlSnap.docs) {
      final data = d.data();
      await WatchlistService.instance.addToWatchlist(
        tmdbId: (data['tmdbId'] as num).toInt(),
        mediaType: data['mediaType'] as String,
        title: data['title'] as String,
        posterPath: data['posterPath'] as String?,
        overview: data['overview'] as String?,
      );
    }

    final schSnap = await _sch.get();
    for (final d in schSnap.docs) {
      final m = d.data();
      await ScheduleService.instance.addSchedule(
        tmdbId: (m['tmdbId'] as num).toInt(),
        mediaType: m['mediaType'] as String,
        title: m['title'] as String,
        posterPath: m['posterPath'] as String?,
        plannedAt: (m['plannedAt'] as Timestamp).toDate(),
        note: m['note'] as String?,
        season: (m['season'] as num?)?.toInt(),
        episode: (m['episode'] as num?)?.toInt(),
        episodesCount: (m['episodesCount'] as num?)?.toInt() ?? 1,
      );
    }
  }

  /// LISTEN: aplica mudanças remotas (tempo real) no Drift.
  void listenRemote() {
    // WATCHLIST
    _wl.snapshots().listen((snap) async {
      // estratégia simples: re-puxa tudo (para começar).
      // Se quiser super fino, compare docChanges e aplique “delta”.
      // Aqui mantemos simples e robusto:
      // Limpeza total local + reimport? Preferível evitar.
      // Opção melhor: só garante inclusão/remoção conforme docs.
      final local = await AppDatabase.instance.select(AppDatabase.instance.mediaItems).get();
      // nada agressivo: só garante que todos remotos existem localmente
      for (final d in snap.docs) {
        final m = d.data();
        await WatchlistService.instance.addToWatchlist(
          tmdbId: (m['tmdbId'] as num).toInt(),
          mediaType: m['mediaType'] as String,
          title: m['title'] as String,
          posterPath: m['posterPath'] as String?,
          overview: m['overview'] as String?,
        );
      }
      // Remoções: se algum doc local não está no remoto, remove da watchlist
      final remoteKeys = snap.docs.map((d) => d.id).toSet();
      // docId que sugeri: "${mediaType}_${tmdbId}"
      // Se você seguir esse padrão, dá pra mapear fácil.
      // (Por simplicidade, pulo remoção automática aqui. Pode ser adicionada depois.)
    });

    // SCHEDULE
    _sch.orderBy('plannedAt').snapshots().listen((snap) async {
      // Para começar, apenas garante inserções locais.
      for (final d in snap.docs) {
        final m = d.data();
        await ScheduleService.instance.addSchedule(
          tmdbId: (m['tmdbId'] as num).toInt(),
          mediaType: m['mediaType'] as String,
          title: m['title'] as String,
          posterPath: m['posterPath'] as String?,
          plannedAt: (m['plannedAt'] as Timestamp).toDate(),
          note: m['note'] as String?,
          season: (m['season'] as num?)?.toInt(),
          episode: (m['episode'] as num?)?.toInt(),
          episodesCount: (m['episodesCount'] as num?)?.toInt() ?? 1,
        );
      }
      // idem: remoção pode ser implementada posteriormente
    });
  }

  /// PUSH: chame isso sempre que alterar localmente
  Future<void> pushWatchlist({
    required int tmdbId,
    required String mediaType,
    required String title,
    String? posterPath,
    String? overview,
  }) async {
    final id = '${mediaType}_${tmdbId}';
    await _wl.doc(id).set({
      'tmdbId': tmdbId,
      'mediaType': mediaType,
      'title': title,
      'posterPath': posterPath,
      'overview': overview,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteWatchlist({
    required int tmdbId,
    required String mediaType,
  }) async {
    await _wl.doc('${mediaType}_${tmdbId}').delete();
  }

  Future<void> pushSchedule({
    required int tmdbId,
    required String mediaType,
    required String title,
    String? posterPath,
    required DateTime plannedAt,
    String? note,
    int? season,
    int? episode,
    int episodesCount = 1,
  }) async {
    await _sch.add({
      'tmdbId': tmdbId,
      'mediaType': mediaType,
      'title': title,
      'posterPath': posterPath,
      'plannedAt': Timestamp.fromDate(plannedAt),
      'note': note,
      'season': season,
      'episode': episode,
      'episodesCount': episodesCount,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSchedule(String docId) async {
    await _sch.doc(docId).delete();
  }
}
