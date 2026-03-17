import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../data/api/tmdb_client.dart';
import '../../../core/db/watchlist_service.dart';
import '../../../core/db/schedule_service.dart';
import '../../../core/time/time_service.dart';
import '../../details/media_details_page.dart';
import 'search_page.dart';
import '../widgets/hero_carousel.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});
  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

enum _Filter { all, movie, tv, anime }

class _DiscoverPageState extends State<DiscoverPage> {
  final _tmdb = TmdbClient();
  static const int _gridPages = 3;
  final Map<int, String> _movieGenres = {};
  final Map<int, String> _tvGenres = {};
  bool _genresLoaded = false;

  late Future<List<Map<String, dynamic>>> _futureCarousel; // FIXO
  late Future<List<Map<String, dynamic>>> _future;          // GRID

  _Filter _filter = _Filter.all;

  static const _imgBase = 'https://image.tmdb.org/t/p/w500';

  @override
  void initState() {
    super.initState();
    _futureCarousel = _loadCarousel(); // carrossel independente
    _future = _load();                 // grid com filtros
  }

  // CARROSSEL: sempre trending all week, nao sofre com filtros
  Future<List<Map<String, dynamic>>> _loadCarousel() async {
    await _ensureGenres();
    final map = await _tmdb.trendingAllWeek();
    return _normalizedItems(
      List<Map<String, dynamic>>.from(map['results'] ?? const []),
    );
  }

  // Normaliza resultados vindos de endpoints diferentes (dedup + media_type)
  bool _isDorama(Map<String, dynamic> m) {
    final mediaType = (m['media_type'] ?? '').toString();
    if (mediaType != 'tv') return false;

    final langs = {'ko', 'ja', 'zh', 'zh-cn', 'zh-tw'};
    final countries = {'KR', 'JP', 'CN', 'TW', 'HK'};

    final origLang = (m['original_language'] ?? '').toString().toLowerCase();
    final originCountry = ((m['origin_country'] as List?) ?? const [])
        .map((e) => e.toString().toUpperCase())
        .toList();

    return langs.contains(origLang) || originCountry.any(countries.contains);
  }

  bool _isAnime(Map<String, dynamic> m) {
    final mediaType = (m['media_type'] ?? '').toString();
    if (mediaType != 'tv') return false;

    final origLang = (m['original_language'] ?? '').toString().toLowerCase();
    final originCountry = ((m['origin_country'] as List?) ?? const [])
        .map((e) => e.toString().toUpperCase())
        .toList();
    final genreIds = (m['genre_ids'] as List?)?.cast<int>() ?? const <int>[];

    final jpSignal = origLang == 'ja' || originCountry.contains('JP');
    return jpSignal && genreIds.contains(16);
  }

  Future<void> _ensureGenres() async {
    if (_genresLoaded) return;

    final responses = await Future.wait([
      _tmdb.movieGenres(),
      _tmdb.tvGenres(),
    ]);

    _movieGenres
      ..clear()
      ..addAll(_toGenreMap(responses[0]['genres']));
    _tvGenres
      ..clear()
      ..addAll(_toGenreMap(responses[1]['genres']));

    _genresLoaded = true;
  }

  Map<int, String> _toGenreMap(dynamic raw) {
    final out = <int, String>{};
    for (final e in (raw as List? ?? const [])) {
      final m = Map<String, dynamic>.from(e as Map);
      final id = (m['id'] as num?)?.toInt();
      final name = (m['name'] ?? '').toString().trim();
      if (id != null && name.isNotEmpty) out[id] = name;
    }
    return out;
  }

  String _typeLabel(String mediaType, {required bool isDorama, required bool isAnime}) {
    if (mediaType == 'movie') return 'Filme';
    if (mediaType == 'tv') {
      if (isAnime) return 'Anime';
      if (isDorama) return 'Dorama';
      return 'Serie';
    }
    return 'Titulo';
  }

  String _genreLabel(Map<String, dynamic> m) {
    final mediaType = (m['media_type'] ?? '').toString();
    final source = mediaType == 'movie' ? _movieGenres : _tvGenres;
    final ids = ((m['genre_ids'] as List?) ?? const [])
        .map((e) => (e as num?)?.toInt())
        .whereType<int>();

    for (final id in ids) {
      final label = source[id];
      if (label != null && label.isNotEmpty) return label;
    }
    return '';
  }

  List<Map<String, dynamic>> _normalizedItems(
    Iterable<Map<String, dynamic>> raw, {
    String? forcedMediaType,
  }) {
    final byKey = <String, Map<String, dynamic>>{};

    for (final item in raw) {
      final idNum = item['id'] as num?;
      if (idNum == null) continue;

      final mediaType = (forcedMediaType ?? item['media_type'] ?? '').toString();
      if (mediaType != 'movie' && mediaType != 'tv') continue;

      final map = Map<String, dynamic>.from(item);
      map['media_type'] = mediaType;
      final isDorama = _isDorama(map);
      final isAnime = _isAnime(map);
      map['is_dorama'] = isDorama;
      map['is_anime'] = isAnime;
      map['type_label'] = _typeLabel(
        mediaType,
        isDorama: isDorama,
        isAnime: isAnime,
      );
      map['genre_label'] = _genreLabel(map);
      byKey['$mediaType:${idNum.toInt()}'] = map;
    }

    final out = byKey.values.toList();
    out.sort((a, b) {
      final pa = (a['popularity'] as num?)?.toDouble() ?? 0;
      final pb = (b['popularity'] as num?)?.toDouble() ?? 0;
      return pb.compareTo(pa);
    });
    return out;
  }

  // GRID principal (afetado pelos filtros)
  Future<List<Map<String, dynamic>>> _load() async {
    await _ensureGenres();
    List<Map<String, dynamic>> items;

    switch (_filter) {
      case _Filter.movie:
        final pages = await Future.wait(
          List.generate(_gridPages, (i) => _tmdb.trendingMovieWeek(page: i + 1)),
        );
        items = _normalizedItems(
          pages.expand(
            (m) => List<Map<String, dynamic>>.from(m['results'] ?? const []),
          ),
          forcedMediaType: 'movie',
        );
        break;
      case _Filter.tv:
        final pages = await Future.wait(
          List.generate(_gridPages, (i) => _tmdb.trendingTvWeek(page: i + 1)),
        );
        items = _normalizedItems(
          pages.expand(
            (m) => List<Map<String, dynamic>>.from(m['results'] ?? const []),
          ),
          forcedMediaType: 'tv',
        );
        break;
      case _Filter.anime:
        final pages = await Future.wait(
          List.generate(_gridPages, (i) => _tmdb.discoverAnime(page: i + 1)),
        );
        items = _normalizedItems(
          pages.expand(
            (m) => List<Map<String, dynamic>>.from(m['results'] ?? const []),
          ),
          forcedMediaType: 'tv',
        );
        items = items.where((e) => (e['is_anime'] ?? false) == true).toList();
        break;
      case _Filter.all:
        final responses = await Future.wait(
          [
            ...List.generate(_gridPages, (i) => _tmdb.trendingMovieWeek(page: i + 1)),
            ...List.generate(_gridPages, (i) => _tmdb.trendingTvWeek(page: i + 1)),
          ],
        );
        items = _normalizedItems(
          responses.expand(
            (m) => List<Map<String, dynamic>>.from(m['results'] ?? const []),
          ),
        );
        break;
    }
    return items;
  }

  Future<void> _refresh() async {
    final f = _load();
    setState(() => _future = f);
    await f;
  }

  void _changeFilter(_Filter f) {
    setState(() {
      _filter = f;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Descobrir'),
        actions: [
          IconButton(
            tooltip: 'Buscar',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SearchPage(tmdb: _tmdb)),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ================= CARROSSEL (FIXO) =================
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureCarousel,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 188,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snap.hasData || (snap.data?.isEmpty ?? true)) {
                return const SizedBox(height: 0);
              }

              final heroItems = snap.data!
                  .where((m) => (m['backdrop_path'] ?? m['poster_path']) != null)
                  .take(5)
                  .toList();

              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: HeroCarousel(
                  items: heroItems,
                  onTapItem: (m) {
                    final poster = m['poster_path'] as String?;
                    final mediaType = (m['media_type'] ?? '') as String;
                    final title = (m['title'] ?? m['name'] ?? '') as String;
                    final genreLabel = (m['genre_label'] ?? '').toString();
                    final vote = (m['vote_average'] ?? 0).toDouble();
                    final tmdbId = (m['id'] as num).toInt();
                    final overview = (m['overview'] ?? '') as String? ?? '';

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailsPage(
                          tmdbId: tmdbId,
                          mediaType: mediaType,
                          title: title,
                          genreLabel: genreLabel,
                          posterPath: poster,
                          overview: overview,
                          rating: vote,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // ================= FILTROS (grid) =================
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _CatChip(
                  label: 'Todos',
                  selected: _filter == _Filter.all,
                  onTap: () => _changeFilter(_Filter.all),
                ),
                _CatChip(
                  label: 'Filmes',
                  selected: _filter == _Filter.movie,
                  onTap: () => _changeFilter(_Filter.movie),
                ),
                _CatChip(
                  label: 'Series',
                  selected: _filter == _Filter.tv,
                  onTap: () => _changeFilter(_Filter.tv),
                ),
                _CatChip(
                  label: 'Animes',
                  selected: _filter == _Filter.anime,
                  onTap: () => _changeFilter(_Filter.anime),
                ),
              ],
            ),
          ),

          // ================= GRID PRINCIPAL =================
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const _GridSkeleton();
                }
                if (snap.hasError) {
                  return _ErrorState(
                    message: 'Falha ao carregar tendencias.\n${snap.error}',
                    onRetry: _refresh,
                  );
                }

                final items = snap.data ?? const [];
                if (items.isEmpty) {
                  return _ErrorState(
                    message: 'Nenhum resultado por aqui.',
                    onRetry: _refresh,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth >= 420 ? 3 : 2;

                      const pad = 10.0;
                      const gap = 10.0;
                      final totalHPad = pad * 2 + gap * (crossAxisCount - 1);
                      final cardW = (constraints.maxWidth - totalHPad) / crossAxisCount;

                      final posterH = cardW * (3 / 2);
                      const infoH = 80.0;
                      final mainAxisExtent = posterH + infoH + 14;

                      return GridView.builder(
                        padding: const EdgeInsets.all(pad),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: gap,
                          crossAxisSpacing: gap,
                          mainAxisExtent: mainAxisExtent,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final it = items[i];
                          final poster = it['poster_path'] as String?;
                          final mediaType = (it['media_type'] ?? '') as String;
                          final isDorama = (it['is_dorama'] ?? false) == true;
                          final isAnime = (it['is_anime'] ?? false) == true;
                          final genreLabel = (it['genre_label'] ?? '').toString();
                          final title = (it['title'] ?? it['name'] ?? '') as String;
                          final vote = (it['vote_average'] ?? 0).toDouble();
                          final tmdbId = (it['id'] as num).toInt();
                          final overview = (it['overview'] ?? '') as String? ?? '';

                          return _PosterCard(
                            imageUrl: poster != null ? '$_imgBase$poster' : null,
                            title: title,
                            mediaType: mediaType,
                            isDorama: isDorama,
                            isAnime: isAnime,
                            genreLabel: genreLabel,
                            rating: vote,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DetailsPage(
                                    tmdbId: tmdbId,
                                    mediaType: mediaType,
                                    title: title,
                                    genreLabel: genreLabel,
                                    posterPath: poster,
                                    overview: overview,
                                    rating: vote,
                                  ),
                                ),
                              );
                            },
                            onAddWatchlist: () async {
                              await WatchlistService.instance.addToWatchlist(
                                tmdbId: tmdbId,
                                mediaType: mediaType,
                                title: title,
                                posterPath: poster,
                                overview: overview,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Adicionado a Watchlist')),
                              );
                            },
                            onSchedule: () => _openScheduleSheet(
                              context: context,
                              tmdbId: tmdbId,
                              mediaType: mediaType,
                              title: title,
                              posterPath: poster,
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: scheme.surface,
    );
  }

  Future<void> _openScheduleSheet({
    required BuildContext context,
    required int tmdbId,
    required String mediaType,
    required String title,
    String? posterPath,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ScheduleSheet(
        tmdb: _tmdb,
        tmdbId: tmdbId,
        mediaType: mediaType,
        title: title,
        posterPath: posterPath,
      ),
    );
  }
}

// ===== UI bits

class _CatChip extends StatelessWidget {
  const _CatChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        selected: selected,
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        selectedColor: scheme.primary.withOpacity(.15),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _PosterCard extends StatelessWidget {
  const _PosterCard({
    required this.title,
    required this.mediaType,
    this.isDorama = false,
    this.isAnime = false,
    this.genreLabel,
    required this.rating,
    required this.onTap,
    required this.onAddWatchlist,
    required this.onSchedule,
    this.imageUrl,
  });

  final String? imageUrl;
  final String title;
  final String mediaType; // 'movie' | 'tv'
  final bool isDorama;
  final bool isAnime;
  final String? genreLabel;
  final double rating;
  final VoidCallback onTap;
  final VoidCallback onAddWatchlist;
  final VoidCallback onSchedule;

  Color get _chipColor =>
      mediaType == 'movie' ? const Color(0xFFF28C18) : const Color(0xFF205295);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.black12),
                        errorWidget: (_, __, ___) => const ColoredBox(
                          color: Colors.black12,
                          child: Center(child: Icon(Icons.broken_image)),
                        ),
                      )
                    : const ColoredBox(
                        color: Color(0x11000000),
                        child: Center(child: Icon(Icons.movie_creation_outlined)),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: _chipColor.withOpacity(.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: _chipColor.withOpacity(.45)),
                            ),
                            child: Text(
                              (genreLabel != null && genreLabel!.isNotEmpty)
                                  ? genreLabel!
                                  : (mediaType == 'movie'
                                      ? 'Filme'
                                      : (isAnime ? 'Anime' : (isDorama ? 'Dorama' : 'Serie'))),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _chipColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rate_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: scheme.onSurface.withOpacity(.8),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _MiniActionIcon(
                        tooltip: 'Minha Lista',
                        icon: Icons.bookmark_add_outlined,
                        onTap: onAddWatchlist,
                      ),
                      const SizedBox(width: 4),
                      _MiniActionIcon(
                        tooltip: 'Agendar',
                        icon: Icons.event_available_outlined,
                        onTap: onSchedule,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniActionIcon extends StatelessWidget {
  const _MiniActionIcon({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 16,
        child: SizedBox(
          width: 22,
          height: 22,
          child: Icon(icon, size: 15),
        ),
      ),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 420 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(10),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: (c.maxWidth / cols) * 1.5 + 90,
          ),
          itemCount: 8,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== SCHEDULE SHEET ======================

class _ScheduleSheet extends StatefulWidget {
  const _ScheduleSheet({
    required this.tmdb,
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterPath,
  });

  final TmdbClient tmdb;
  final int tmdbId;
  final String mediaType; // 'movie' | 'tv'
  final String title;
  final String? posterPath;

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  NowInfo? _nowInfo;
  late DateTime _openedAtTrusted;
  late Stopwatch _sw;
  Timer? _ticker;
  DateTime? _baseLiveLocal;
  DateTime? get _liveNow =>
      _baseLiveLocal == null ? null : _baseLiveLocal!.add(_sw.elapsed);

  DateTime _date = DateTime(2000);

  List<int> _seasons = const [];
  int? _selectedSeason;

  List<_EpItem> _episodes = const [];
  int? _selectedEpisode;

  String? get _selectedEpisodeName {
    final ep = _episodes.firstWhere(
      (e) => e.episodeNumber == _selectedEpisode,
      orElse: () => _EpItem(episodeNumber: 0, name: '', airDate: null),
    );
    return ep.name.isEmpty ? null : ep.name;
  }

  DateTime? get _selectedEpisodeAirDate {
    final ep = _episodes.firstWhere(
      (e) => e.episodeNumber == _selectedEpisode,
      orElse: () => _EpItem(episodeNumber: 0, name: '', airDate: null),
    );
    return ep.airDate;
  }

  final _noteCtrl = TextEditingController();
  DateTime? _movieReleaseDate;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _sw.stop();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      _nowInfo = await TimeService.instance.fetchNow();
      final base = _nowInfo!.preferredLocal;
      _openedAtTrusted = base;

      _date = DateTime(base.year, base.month, base.day);

      _baseLiveLocal = base;
      _sw = Stopwatch()..start();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });

      if (widget.mediaType == 'tv') {
        final details = await widget.tmdb.tvDetails(widget.tmdbId);
        final seasons = (details['seasons'] as List<dynamic>? ?? const [])
            .map((e) => (e as Map)['season_number'])
            .whereType<int>()
            .where((n) => n > 0)
            .toList()
          ..sort();
        _seasons = seasons;
        _selectedSeason = seasons.isNotEmpty ? seasons.first : null;
        if (_selectedSeason != null) {
          await _loadEpisodesForSeason(_selectedSeason!);
        }
      } else {
        try {
          final md = await widget.tmdb.movieDetails(widget.tmdbId);
          _movieReleaseDate = _parseTmdbDateOnly(md['release_date'] as String?);
        } catch (_) {}
      }
    } catch (e) {
      _error = 'Falha ao obter dados. $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadEpisodesForSeason(int seasonNumber) async {
    setState(() {
      _loading = true;
      _episodes = const [];
      _selectedEpisode = null;
    });
    try {
      final season = await widget.tmdb.tvSeason(widget.tmdbId, seasonNumber);
      final eps = (season['episodes'] as List<dynamic>? ?? const [])
          .map((e) {
            final m = e as Map<String, dynamic>;
            return _EpItem(
              episodeNumber: (m['episode_number'] as num?)?.toInt() ?? 0,
              name: (m['name'] as String?) ?? '',
              airDate: _parseTmdbDateOnly(m['air_date'] as String?),
            );
          })
          .where((ep) => ep.episodeNumber > 0)
          .toList()
        ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));

      _episodes = eps;
      if (_episodes.isNotEmpty) {
        _selectedEpisode = _episodes.first.episodeNumber;
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime(_openedAtTrusted.year, _openedAtTrusted.month, _openedAtTrusted.day);
    final d = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      initialDate: _date.isBefore(today) ? today : _date,
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    final plannedAt = DateTime(_date.year, _date.month, _date.day, 12, 0);

    int? season;
    int? episode;

    if (widget.mediaType == 'tv') {
      season = _selectedSeason;
      episode = _selectedEpisode;
    }

    final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();

    await ScheduleService.instance.addSchedule(
      tmdbId: widget.tmdbId,
      mediaType: widget.mediaType,
      title: widget.title,
      posterPath: widget.posterPath,
      plannedAt: plannedAt,
      note: note,
      season: season,
      episode: episode,
    );

    if (!mounted) return;
    Navigator.pop(context);
    final seText = (season != null && episode != null) ? ' (S${season}E${episode})' : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sessao agendada: ${widget.title}$seText - ${_fmtDate(plannedAt)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 8,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _loading
            ? const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
            : _error != null
                ? SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 40),
                          const SizedBox(height: 8),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                _loading = true;
                                _error = null;
                              });
                              _init();
                            },
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Agendar: ${widget.title}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 8),

                        if (_liveNow != null) ...[
                          Text(
                            'Agora (srv): ${_fmtDate(_liveNow!)} ${_fmtTime(TimeOfDay.fromDateTime(_liveNow!))}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(.70),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        if (widget.mediaType == 'tv') ...[
                          DropdownButtonFormField<int>(
                            value: _selectedSeason,
                            decoration: const InputDecoration(
                              labelText: 'Temporada',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: _seasons
                                .map((s) => DropdownMenuItem(value: s, child: Text('Temporada $s')))
                                .toList(),
                            onChanged: (v) async {
                              if (v == null) return;
                              setState(() => _selectedSeason = v);
                              await _loadEpisodesForSeason(v);
                            },
                          ),
                          const SizedBox(height: 10),

                          DropdownButtonFormField<int>(
                            value: _selectedEpisode,
                            decoration: const InputDecoration(
                              labelText: 'Episodio',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: _episodes.map((e) {
                              final text = 'E${e.episodeNumber.toString().padLeft(2, '0')}';
                              return DropdownMenuItem(
                                value: e.episodeNumber,
                                child: Text(text, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedEpisode = v),
                          ),
                          const SizedBox(height: 6),

                          Builder(builder: (_) {
                            final name = _selectedEpisodeName;
                            final air = _selectedEpisodeAirDate;
                            final info = [
                              if (name != null) 'Titulo: $name',
                              'Data oficial (TMDB): ${air != null ? _fmtDate(air) : '-'}',
                            ].join(' - ');
                            return Text(
                              info,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(.75),
                              ),
                            );
                          }),
                          const SizedBox(height: 6),

                          const SizedBox(height: 12),
                        ],

                        OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.event),
                          label: Text(_fmtDate(_date)),
                        ),

                        if (widget.mediaType == 'movie') ...[
                          const SizedBox(height: 8),
                          Text(
                            'Data oficial (TMDB): ${_movieReleaseDate != null ? _fmtDate(_movieReleaseDate!) : '-'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurface.withOpacity(.75),
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        TextField(
                          controller: _noteCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Anotacoes (opcional)',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.check),
                            label: const Text('Salvar agendamento'),
                            onPressed: _save,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar', style: TextStyle(color: scheme.primary)),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  static DateTime? _parseTmdbDateOnly(String? s) {
    if (s == null || s.isEmpty) return null;
    final p = s.split('-');
    if (p.length != 3) return null;
    final y = int.tryParse(p[0]), m = int.tryParse(p[1]), d = int.tryParse(p[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _EpItem {
  final int episodeNumber;
  final String name;
  final DateTime? airDate;
  _EpItem({required this.episodeNumber, required this.name, required this.airDate});
}

