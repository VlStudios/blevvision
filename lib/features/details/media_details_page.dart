import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/db/watchlist_service.dart';
import '../../core/db/schedule_service.dart';
import '../../data/api/tmdb_client.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({
    super.key,
    required this.tmdbId,
    required this.mediaType, // 'movie' | 'tv'
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.rating,
    this.genreLabel,
  });

  final int tmdbId;
  final String mediaType;
  final String title;
  final String? posterPath;
  final String overview;
  final double rating;
  final String? genreLabel;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  static const _imgBase = 'https://image.tmdb.org/t/p/w500';
  bool _overviewExpanded = false;

  Future<void> _addToWatchlist() async {
    await WatchlistService.instance.addToWatchlist(
      tmdbId: widget.tmdbId,
      mediaType: widget.mediaType,
      title: widget.title,
      posterPath: widget.posterPath,
      overview: widget.overview,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adicionado a Minha Lista')),
    );
  }

  Future<void> _openScheduleSheet() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _ScheduleSheetDetails(
        tmdbId: widget.tmdbId,
        mediaType: widget.mediaType,
        title: widget.title,
        posterPath: widget.posterPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chipColor =
        widget.mediaType == 'movie' ? const Color(0xFFF28C18) : const Color(0xFF205295);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: widget.posterPath != null
                      ? CachedNetworkImage(
                          imageUrl: '$_imgBase${widget.posterPath}',
                          fit: BoxFit.cover,
                        )
                      : const ColoredBox(color: Color(0x11000000)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: chipColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  (widget.genreLabel != null && widget.genreLabel!.isNotEmpty)
                      ? widget.genreLabel!
                      : (widget.mediaType == 'movie' ? 'Filme' : 'Serie'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star_rate_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 3),
                  Text(
                    widget.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.1),
          ),
          const SizedBox(height: 6),
          if (widget.overview.trim().isNotEmpty) ...[
            Text(
              widget.overview,
              maxLines: _overviewExpanded ? null : 4,
              overflow: _overviewExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface.withOpacity(.82),
                fontSize: 13,
                height: 1.35,
              ),
            ),
            if (widget.overview.length > 180)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _overviewExpanded = !_overviewExpanded),
                  child: Text(_overviewExpanded ? 'Ver menos' : 'Ver mais'),
                ),
              ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _addToWatchlist,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('Minha Lista'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openScheduleSheet,
                  icon: const Icon(Icons.event_available_outlined, size: 18),
                  label: const Text('Agendar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleSheetDetails extends StatefulWidget {
  const _ScheduleSheetDetails({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterPath,
  });

  final int tmdbId;
  final String mediaType;
  final String title;
  final String? posterPath;

  @override
  State<_ScheduleSheetDetails> createState() => _ScheduleSheetDetailsState();
}

class _ScheduleSheetDetailsState extends State<_ScheduleSheetDetails> {
  final _tmdb = TmdbClient();

  DateTime _date = DateTime.now();
  final _noteCtrl = TextEditingController();

  bool _loadingTv = false;
  List<int> _seasons = const [];
  int? _selectedSeason;
  List<_EpisodeOption> _episodes = const [];
  int? _selectedEpisode;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == 'tv') {
      _initTvData();
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _initTvData() async {
    setState(() => _loadingTv = true);
    try {
      final details = await _tmdb.tvDetails(widget.tmdbId);
      final seasons = (details['seasons'] as List<dynamic>? ?? const [])
          .map((e) => (e as Map)['season_number'])
          .whereType<int>()
          .where((n) => n > 0)
          .toList()
        ..sort();

      if (!mounted) return;
      setState(() {
        _seasons = seasons;
        _selectedSeason = seasons.isNotEmpty ? seasons.first : null;
      });

      if (_selectedSeason != null) {
        await _loadEpisodes(_selectedSeason!);
      }
    } finally {
      if (mounted) setState(() => _loadingTv = false);
    }
  }

  Future<void> _loadEpisodes(int seasonNumber) async {
    setState(() {
      _episodes = const [];
      _selectedEpisode = null;
    });

    final season = await _tmdb.tvSeason(widget.tmdbId, seasonNumber);
    final episodes = (season['episodes'] as List<dynamic>? ?? const [])
        .map((e) {
          final m = e as Map<String, dynamic>;
          final n = (m['episode_number'] as num?)?.toInt() ?? 0;
          final name = (m['name'] as String?) ?? '';
          return _EpisodeOption(number: n, name: name);
        })
        .where((e) => e.number > 0)
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    if (!mounted) return;
    setState(() {
      _episodes = episodes;
      _selectedEpisode = episodes.isNotEmpty ? episodes.first.number : null;
    });
  }

  Future<void> _save() async {
    final dt = DateTime(_date.year, _date.month, _date.day, 12, 0);

    await ScheduleService.instance.addSchedule(
      tmdbId: widget.tmdbId,
      mediaType: widget.mediaType,
      title: widget.title,
      posterPath: widget.posterPath,
      plannedAt: dt,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      season: widget.mediaType == 'tv' ? _selectedSeason : null,
      episode: widget.mediaType == 'tv' ? _selectedEpisode : null,
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sessao agendada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Agendar: ${widget.title}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (widget.mediaType == 'tv') ...[
              if (_loadingTv)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                )
              else ...[
                DropdownButtonFormField<int>(
                  value: _selectedSeason,
                  decoration: const InputDecoration(
                    labelText: 'Temporada',
                    border: OutlineInputBorder(),
                  ),
                  items: _seasons
                      .map((s) => DropdownMenuItem(value: s, child: Text('Temporada $s')))
                      .toList(),
                  onChanged: (v) async {
                    if (v == null) return;
                    setState(() => _selectedSeason = v);
                    await _loadEpisodes(v);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _selectedEpisode,
                  decoration: const InputDecoration(
                    labelText: 'Episodio',
                    border: OutlineInputBorder(),
                  ),
                  items: _episodes.map((e) {
                    final label = e.name.isEmpty
                        ? 'E${e.number.toString().padLeft(2, '0')}'
                        : 'E${e.number.toString().padLeft(2, '0')} - ${e.name}';
                    return DropdownMenuItem(value: e.number, child: Text(label, overflow: TextOverflow.ellipsis));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedEpisode = v),
                ),
                const SizedBox(height: 12),
              ],
            ],
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDate: _date,
                );
                if (d != null) setState(() => _date = d);
              },
              icon: const Icon(Icons.event),
              label: Text(
                '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
              ),
            ),
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
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeOption {
  const _EpisodeOption({required this.number, required this.name});

  final int number;
  final String name;
}
