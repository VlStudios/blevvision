import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/db/app_db.dart';
import '../../core/db/schedule_service.dart';
import '../../data/api/tmdb_client.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const _imgBase = 'https://image.tmdb.org/t/p/w185';
  final _service = ScheduleService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: StreamBuilder<List<(ScheduleItem, MediaItem)>>( 
        stream: _service.watchUpcoming(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rows = snap.data ?? const [];
          if (rows.isEmpty) {
            return const Center(child: Text('Nada agendado ainda.'));
          }

          final groups = _groupRows(rows);

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final g = groups[i];
              if (g.media.mediaType == 'tv') {
                return _buildSeriesGroup(g);
              }
              return _buildMovieItem(g);
            },
          );
        },
      ),
    );
  }

  List<_MediaGroup> _groupRows(List<(ScheduleItem, MediaItem)> rows) {
    final map = <int, _MediaGroup>{};

    for (final row in rows) {
      final sched = row.$1;
      final media = row.$2;
      final group = map.putIfAbsent(media.id, () => _MediaGroup(media: media, items: []));
      group.items.add(sched);
    }

    final groups = map.values.toList();
    for (final g in groups) {
      g.items.sort((a, b) => a.plannedAt.compareTo(b.plannedAt));
    }

    groups.sort((a, b) => a.items.first.plannedAt.compareTo(b.items.first.plannedAt));
    return groups;
  }

  Widget _buildPoster(String? posterPath) {
    final url = posterPath == null ? null : '$_imgBase$posterPath';
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 44,
        height: 64,
        child: url == null
            ? const ColoredBox(
                color: Color(0x11000000),
                child: Icon(Icons.movie_outlined, size: 18),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: Color(0x11000000),
                  child: Icon(Icons.broken_image_outlined, size: 18),
                ),
              ),
      ),
    );
  }

  Widget _buildMovieItem(_MediaGroup g) {
    final sched = g.items.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(g.media.posterPath),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.media.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Filme',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  Text('Data: ${_fmtDate(sched.plannedAt)}'),
                  const SizedBox(height: 4),
                  StreamBuilder<ProgressData?>(
                    stream: _service.watchLatestProgressForMedia(g.media.id),
                    builder: (_, snap) {
                      return Text(
                        _progressSentence(snap.data),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final saved = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => _ProgressPage(
                            media: g.media,
                            initialSchedule: sched,
                          ),
                        ),
                      );
                      if (!mounted || saved != true) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Progresso salvo')),
                      );
                    },
                    icon: const Icon(Icons.bookmark_added_outlined),
                    label: const Text('Marcar onde parou'),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  tooltip: 'Editar agendamento',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _openScheduleEditPage(
                    media: g.media,
                    sched: sched,
                  ),
                ),
                IconButton(
                  tooltip: 'Remover',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmRemoveSchedule(sched),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesGroup(_MediaGroup g) {
    final next = g.items.first;

    return Card(
      child: ExpansionTile(
        leading: _buildPoster(g.media.posterPath),
        title: Text(g.media.title),
        subtitle: StreamBuilder<ProgressData?>(
          stream: _service.watchLatestProgressForMedia(g.media.id),
          builder: (_, snap) {
            final p = snap.data;
            final progressText = _progressSentence(p);
            return Text('Proximo: ${_fmtDate(next.plannedAt)}\n$progressText');
          },
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final saved = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => _ProgressPage(
                          media: g.media,
                          initialSchedule: next,
                        ),
                      ),
                    );
                    if (!mounted || saved != true) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Progresso salvo')),
                    );
                  },
                  icon: const Icon(Icons.bookmark_added_outlined),
                  label: const Text('Marcar onde parou'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...g.items.map((sched) {
            final se = [
              if (sched.season != null) 'T${sched.season}',
              if (sched.episode != null) 'E${sched.episode}',
            ].join('');

            final subtitle = [
              'Data: ${_fmtDate(sched.plannedAt)}',
              if ((sched.note ?? '').trim().isNotEmpty) 'Obs: ${sched.note!.trim()}',
            ].join('\n');

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.event_note_outlined),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          se.isEmpty ? 'Episodio agendado' : se,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(subtitle),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        tooltip: 'Editar agendamento',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openScheduleEditPage(
                          media: g.media,
                          sched: sched,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remover',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmRemoveSchedule(sched),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _progressSentence(ProgressData? p) {
    if (p == null) {
      return 'Parou em 00:00:00';
    }
    if (p.season == null && p.episode == null) {
      return 'Parou em ${_fmtHms(p.positionSec)}';
    }
    final season = p.season?.toString() ?? '-';
    final episode = p.episode?.toString() ?? '-';
    return 'Parou na temporada $season, episodio $episode, em ${_fmtHms(p.positionSec)}';
  }

  Future<void> _openScheduleEditPage({
    required MediaItem media,
    required ScheduleItem sched,
  }) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ScheduleEditPage(media: media, sched: sched),
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agendamento atualizado')),
    );
  }

  Future<void> _confirmRemoveSchedule(ScheduleItem sched) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir agendamento?'),
        content: const Text(
          'Esse agendamento sera removido da Agenda. Voce pode criar outro depois, mas esta acao remove o item atual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    await _service.removeSchedule(sched.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agendamento removido')),
    );
  }

  String _fmtDate(DateTime dt) {
    return '${_two(dt.day)}/${_two(dt.month)}/${dt.year}';
  }

  String _fmtHms(int totalSec) {
    final s = totalSec < 0 ? 0 : totalSec;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final ss = s % 60;
    return '${_two(h)}:${_two(m)}:${_two(ss)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

class _ProgressPage extends StatefulWidget {
  const _ProgressPage({
    required this.media,
    this.initialSchedule,
  });

  final MediaItem media;
  final ScheduleItem? initialSchedule;

  @override
  State<_ProgressPage> createState() => _ProgressPageState();
}

class _ScheduleEditSheet extends StatefulWidget {
  const _ScheduleEditSheet({
    required this.media,
    required this.sched,
  });

  final MediaItem media;
  final ScheduleItem sched;

  @override
  State<_ScheduleEditSheet> createState() => _ScheduleEditSheetState();
}

class ScheduleEditPage extends StatelessWidget {
  const ScheduleEditPage({
    required this.media,
    required this.sched,
  });

  final MediaItem media;
  final ScheduleItem sched;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar agendamento')),
      body: SafeArea(
        child: _ScheduleEditSheet(
          media: media,
          sched: sched,
        ),
      ),
    );
  }
}

class _ScheduleEditSheetState extends State<_ScheduleEditSheet> {
  final _service = ScheduleService.instance;
  final _tmdb = TmdbClient();
  late DateTime _date;
  late TextEditingController _noteCtrl;
  bool _loadingTv = false;
  List<int> _seasons = const [];
  int? _selectedSeason;
  List<_ScheduleEpisodeOption> _episodes = const [];
  int? _selectedEpisode;

  @override
  void initState() {
    super.initState();
    _date = widget.sched.plannedAt;
    _noteCtrl = TextEditingController(text: widget.sched.note ?? '');
    _selectedSeason = widget.sched.season;
    _selectedEpisode = widget.sched.episode;
    if (widget.media.mediaType == 'tv') {
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
      final details = await _tmdb.tvDetails(widget.media.tmdbId);
      final seasons = (details['seasons'] as List<dynamic>? ?? const [])
          .map((e) => (e as Map)['season_number'])
          .whereType<int>()
          .where((n) => n > 0)
          .toList()
        ..sort();

      if (!mounted) return;
      setState(() {
        _seasons = seasons;
        _selectedSeason ??= seasons.isNotEmpty ? seasons.first : null;
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
    });

    final season = await _tmdb.tvSeason(widget.media.tmdbId, seasonNumber);
    final episodes = (season['episodes'] as List<dynamic>? ?? const [])
        .map((e) {
          final m = e as Map<String, dynamic>;
          final n = (m['episode_number'] as num?)?.toInt() ?? 0;
          final name = (m['name'] as String?) ?? '';
          return _ScheduleEpisodeOption(number: n, name: name);
        })
        .where((e) => e.number > 0)
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    if (!mounted) return;
    setState(() {
      _episodes = episodes;
      _selectedEpisode = episodes.any((e) => e.number == _selectedEpisode)
          ? _selectedEpisode
          : (episodes.isNotEmpty ? episodes.first.number : null);
    });
  }

  Future<void> _save() async {
    await _service.updateSchedule(
      scheduleId: widget.sched.id,
      dateOnly: _date,
      season: widget.media.mediaType == 'tv' ? _selectedSeason : null,
      episode: widget.media.mediaType == 'tv' ? _selectedEpisode : null,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    if (!mounted) return;
    Navigator.pop(context, true);
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.media.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (widget.media.mediaType == 'tv') ...[
              if (_loadingTv)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
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
                    return DropdownMenuItem(
                      value: e.number,
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedEpisode = v),
                ),
              ],
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: () async {
                final today = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(today.year - 1),
                  lastDate: DateTime(today.year + 5),
                  initialDate: _date,
                );
                if (picked != null) setState(() => _date = picked);
              },
              icon: const Icon(Icons.event_outlined),
              label: Text(
                '${_two(_date.day)}/${_two(_date.month)}/${_date.year}',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Anotacoes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Salvar alteracoes'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

class _ProgressPageState extends State<_ProgressPage> {
  final _service = ScheduleService.instance;
  final _tmdb = TmdbClient();
  final _hourCtrl = TextEditingController(text: '00');
  final _minuteCtrl = TextEditingController(text: '00');
  final _secondCtrl = TextEditingController(text: '00');

  bool _completed = false;
  bool _loading = true;
  bool _loadingTv = false;
  List<int> _seasons = const [];
  int? _selectedSeason;
  List<_ScheduleEpisodeOption> _episodes = const [];
  int? _selectedEpisode;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    _secondCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final latest = await _service.watchLatestProgressForMedia(widget.media.id).first;
    if (!mounted) return;

    setState(() {
      _selectedSeason = latest?.season ?? widget.initialSchedule?.season;
      _selectedEpisode = latest?.episode ?? widget.initialSchedule?.episode;
      final parts = _splitHms(latest?.positionSec ?? 0);
      _hourCtrl.text = parts.$1;
      _minuteCtrl.text = parts.$2;
      _secondCtrl.text = parts.$3;
      _completed = latest?.completed ?? false;
    });

    if (widget.media.mediaType == 'tv') {
      await _initTvData();
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _initTvData() async {
    setState(() => _loadingTv = true);
    try {
      final details = await _tmdb.tvDetails(widget.media.tmdbId);
      final seasons = (details['seasons'] as List<dynamic>? ?? const [])
          .map((e) => (e as Map)['season_number'])
          .whereType<int>()
          .where((n) => n > 0)
          .toList()
        ..sort();

      if (!mounted) return;
      setState(() {
        _seasons = seasons;
        _selectedSeason ??= seasons.isNotEmpty ? seasons.first : null;
      });

      if (_selectedSeason != null) {
        await _loadEpisodes(_selectedSeason!);
      }
    } finally {
      if (mounted) setState(() => _loadingTv = false);
    }
  }

  Future<void> _loadEpisodes(int seasonNumber) async {
    setState(() => _episodes = const []);

    final season = await _tmdb.tvSeason(widget.media.tmdbId, seasonNumber);
    final episodes = (season['episodes'] as List<dynamic>? ?? const [])
        .map((e) {
          final m = e as Map<String, dynamic>;
          final n = (m['episode_number'] as num?)?.toInt() ?? 0;
          final name = (m['name'] as String?) ?? '';
          return _ScheduleEpisodeOption(number: n, name: name);
        })
        .where((e) => e.number > 0)
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    if (!mounted) return;
    setState(() {
      _episodes = episodes;
      _selectedEpisode = episodes.any((e) => e.number == _selectedEpisode)
          ? _selectedEpisode
          : (episodes.isNotEmpty ? episodes.first.number : null);
    });
  }

  Future<void> _save() async {
    final hour = int.tryParse(_hourCtrl.text.trim()) ?? 0;
    final minute = int.tryParse(_minuteCtrl.text.trim()) ?? 0;
    final second = int.tryParse(_secondCtrl.text.trim()) ?? 0;
    final sec = _toSeconds(hour, minute, second);

    await _service.upsertProgress(
      mediaId: widget.media.id,
      season: widget.media.mediaType == 'tv' ? _selectedSeason : null,
      episode: widget.media.mediaType == 'tv' ? _selectedEpisode : null,
      positionSec: sec,
      completed: _completed,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onde voce parou')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                Text(
                  widget.media.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 12),
                if (widget.media.mediaType == 'tv') ...[
                  if (_loadingTv)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
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
                        return DropdownMenuItem(
                          value: e.number,
                          child: Text(label, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedEpisode = v),
                    ),
                  ],
                  const SizedBox(height: 12),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.movie_outlined),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Para filme, salve apenas o tempo onde voce parou.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const Text(
                  'Tempo onde parou',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _hourCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                          hintText: '00',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(':', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _minuteCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Minuto',
                          hintText: '00',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(':', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _secondCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Segundo',
                          hintText: '00',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Formato atual: ${_previewHms()}',
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _completed,
                  onChanged: (v) => setState(() => _completed = v),
                  title: const Text('Concluido'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Salvar progresso'),
                ),
              ],
            ),
    );
  }

  String _fmtHms(int totalSec) {
    final s = totalSec < 0 ? 0 : totalSec;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final ss = s % 60;
    return '${_two(h)}:${_two(m)}:${_two(ss)}';
  }

  (String, String, String) _splitHms(int totalSec) {
    final s = totalSec < 0 ? 0 : totalSec;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final ss = s % 60;
    return (_two(h), _two(m), _two(ss));
  }

  int _toSeconds(int hour, int minute, int second) {
    final safeHour = hour < 0 ? 0 : hour;
    final safeMinute = minute < 0 ? 0 : minute;
    final safeSecond = second < 0 ? 0 : second;
    return safeHour * 3600 + safeMinute * 60 + safeSecond;
  }

  String _previewHms() {
    final hour = int.tryParse(_hourCtrl.text.trim()) ?? 0;
    final minute = int.tryParse(_minuteCtrl.text.trim()) ?? 0;
    final second = int.tryParse(_secondCtrl.text.trim()) ?? 0;
    return _fmtHms(_toSeconds(hour, minute, second));
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

class _MediaGroup {
  _MediaGroup({required this.media, required this.items});

  final MediaItem media;
  final List<ScheduleItem> items;
}

class _ScheduleEpisodeOption {
  const _ScheduleEpisodeOption({
    required this.number,
    required this.name,
  });

  final int number;
  final String name;
}
