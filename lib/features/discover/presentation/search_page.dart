import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../data/api/tmdb_client.dart';
import '../../details/media_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.tmdb});
  final TmdbClient tmdb;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

enum _SFilter { all, movie, tv, anime }

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  Timer? _deb;
  _SFilter _filter = _SFilter.all;
  final Map<int, String> _movieGenres = {};
  final Map<int, String> _tvGenres = {};
  bool _genresLoaded = false;

  static const _imgBase = 'https://image.tmdb.org/t/p/w500';

  List<Map<String, dynamic>> _results = const [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    _deb?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String _) {
    _deb?.cancel();
    _deb = Timer(const Duration(milliseconds: 400), _search);
  }

  Future<void> _ensureGenres() async {
    if (_genresLoaded) return;

    final responses = await Future.wait([
      widget.tmdb.movieGenres(),
      widget.tmdb.tvGenres(),
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

  bool _isDorama(Map<String, dynamic> m) {
    final mediaType = (m['media_type'] ?? '') as String;
    if (mediaType != 'tv') return false;
    final langs = {'ko', 'ja', 'zh', 'zh-cn', 'zh-tw'};
    final countries = {'KR', 'JP', 'CN', 'TW', 'HK'};

    final origLang = (m['original_language'] ?? '').toString().toLowerCase();
    final originCountry = ((m['origin_country'] as List?) ?? const [])
        .map((e) => e.toString().toUpperCase())
        .toList();
    final genreIds = (m['genre_ids'] as List?)?.cast<int>() ?? const <int>[];

    final langHit = langs.contains(origLang);
    final countryHit = originCountry.any(countries.contains);
    if (langHit || countryHit) return true;
    return genreIds.contains(18) && origLang.isNotEmpty;
  }

  bool _isAnime(Map<String, dynamic> m) {
    final mediaType = (m['media_type'] ?? '') as String;
    if (mediaType != 'tv') return false;

    final origLang = (m['original_language'] ?? '').toString().toLowerCase();
    final originCountry = ((m['origin_country'] as List?) ?? const [])
        .map((e) => e.toString().toUpperCase())
        .toList();
    final genreIds = (m['genre_ids'] as List?)?.cast<int>() ?? const <int>[];

    final jpSignal = origLang == 'ja' || originCountry.contains('JP');
    return jpSignal && genreIds.contains(16);
  }

  Future<void> _search() async {
    await _ensureGenres();

    final q = _ctrl.text.trim();
    if (q.isEmpty) {
      setState(() {
        _results = const [];
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final map = await widget.tmdb.searchMulti(q);
      List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from(map['results'] ?? const []);

      switch (_filter) {
        case _SFilter.movie:
          items = items.where((e) => (e['media_type'] ?? '') == 'movie').toList();
          break;
        case _SFilter.tv:
          items = items.where((e) => (e['media_type'] ?? '') == 'tv').toList();
          break;
        case _SFilter.anime:
          items = items.where(_isAnime).toList();
          break;
        case _SFilter.all:
          items = items
              .where((e) =>
                  (e['media_type'] ?? '') == 'movie' ||
                  (e['media_type'] ?? '') == 'tv')
              .toList();
          break;
      }

      items = items.map((e) {
        final m = Map<String, dynamic>.from(e);
        final isDorama = _isDorama(m);
        final isAnime = _isAnime(m);
        m['is_dorama'] = isDorama;
        m['is_anime'] = isAnime;
        m['type_label'] = _typeLabel(
          (m['media_type'] ?? '').toString(),
          isDorama: isDorama,
          isAnime: isAnime,
        );
        m['genre_label'] = _genreLabel(m);
        return m;
      }).toList();

      setState(() => _results = items);
    } catch (e) {
      setState(() => _error = 'Falha na busca: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar filmes e series...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(right: 8),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          onChanged: _onQueryChanged,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _ctrl.clear();
              setState(() => _results = const []);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // filtros
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _SChip(label: 'Todos', sel: _filter == _SFilter.all, onTap: () { setState(()=>_filter=_SFilter.all); _search(); }),
                _SChip(label: 'Filmes', sel: _filter == _SFilter.movie, onTap: () { setState(()=>_filter=_SFilter.movie); _search(); }),
                _SChip(label: 'Series', sel: _filter == _SFilter.tv, onTap: () { setState(()=>_filter=_SFilter.tv); _search(); }),
                _SChip(label: 'Animes', sel: _filter == _SFilter.anime, onTap: () { setState(()=>_filter=_SFilter.anime); _search(); }),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const _SearchSkeleton()
                : _error != null
                    ? Center(child: Text(_error!))
                    : _results.isEmpty
                        ? const Center(child: Text('Busque por um titulo...'))
                        : LayoutBuilder(
                            builder: (context, c) {
                              final cols = c.maxWidth >= 420 ? 3 : 2;
                              final pad = 10.0;
                              final gap = 10.0;
                              final totalHPad = pad * 2 + gap * (cols - 1);
                              final cardW = (c.maxWidth - totalHPad) / cols;
                              final posterH = cardW * (3 / 2);
                              const infoH = 64.0;
                              final extent = posterH + infoH + 14;

                              return GridView.builder(
                                padding: const EdgeInsets.all(10),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  mainAxisExtent: extent,
                                ),
                                itemCount: _results.length,
                                itemBuilder: (_, i) {
                                  final it = _results[i];
                                  final poster = it['poster_path'] as String?;
                                  final mediaType = (it['media_type'] ?? '') as String;
                                  final isDorama = (it['is_dorama'] ?? false) == true;
                                  final isAnime = (it['is_anime'] ?? false) == true;
                                  final genreLabel = (it['genre_label'] ?? '').toString();
                                  final title = (it['title'] ?? it['name'] ?? '') as String;
                                  final vote = (it['vote_average'] ?? 0).toDouble();
                                  final tmdbId = (it['id'] as num).toInt();
                                  final overview = (it['overview'] ?? '') as String? ?? '';

                                  return _ResultCard(
                                    imageUrl: poster != null ? '$_imgBase$poster' : null,
                                    title: title,
                                    mediaType: mediaType,
                                    isDorama: isDorama,
                                    isAnime: isAnime,
                                    genreLabel: genreLabel,
                                    rating: vote,
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => DetailsPage(
                                          tmdbId: tmdbId,
                                          mediaType: mediaType,
                                          title: title,
                                          genreLabel: genreLabel,
                                          posterPath: poster,
                                          overview: overview,
                                          rating: vote,
                                        ),
                                      ));
                                    },
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
      backgroundColor: scheme.surface,
    );
  }
}

class _SChip extends StatelessWidget {
  const _SChip({required this.label, required this.sel, required this.onTap});
  final String label;
  final bool sel;
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
        selected: sel,
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        selectedColor: scheme.primary.withOpacity(.15),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.mediaType,
    this.isDorama = false,
    this.isAnime = false,
    this.genreLabel,
    required this.rating,
    required this.onTap,
    this.imageUrl,
  });

  final String? imageUrl;
  final String title;
  final String mediaType; // movie | tv
  final bool isDorama;
  final bool isAnime;
  final String? genreLabel;
  final double rating;
  final VoidCallback onTap;

  Color get _chipColor => mediaType == 'movie' ? const Color(0xFFF28C18) : const Color(0xFF205295);

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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0,6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 2/3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!, fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.black12),
                        errorWidget: (_, __, ___) => const ColoredBox(
                          color: Colors.black12, child: Center(child: Icon(Icons.broken_image)),
                        ),
                      )
                    : const ColoredBox(color: Color(0x11000000), child: Center(child: Icon(Icons.movie_creation_outlined))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
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
                          style: TextStyle(
                            color: _chipColor, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: .2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rate_rounded, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(color: scheme.onSurface.withOpacity(.8), fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w800, height: 1.05, fontSize: 12.5),
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

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 420 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(10),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: (c.maxWidth / cols) * 1.5 + 90,
          ),
          itemCount: 8,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(14)),
          ),
        );
      },
    );
  }
}

