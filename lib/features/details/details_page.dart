import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/db/watchlist_service.dart';
import '../../core/db/schedule_service.dart';

class DetailsPage extends StatelessWidget {
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

  static const _imgBase = 'https://image.tmdb.org/t/p/w500';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fabAdd',
            onPressed: () async {
              await WatchlistService.instance.addToWatchlist(
                tmdbId: tmdbId,
                mediaType: mediaType,
                title: title,
                posterPath: posterPath,
                overview: overview,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Adicionado à sua Lista ✅')),
                );
              }
            },
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Minha Lista'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'fabSched',
            onPressed: () {
              _openScheduleSheet(
                context: context,
                tmdbId: tmdbId,
                mediaType: mediaType,
                title: title,
                posterPath: posterPath,
              );
            },
            icon: const Icon(Icons.event_available_outlined),
            label: const Text('Agendar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Poster
          AspectRatio(
            aspectRatio: 2/3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: posterPath != null
                  ? CachedNetworkImage(
                      imageUrl: '$_imgBase$posterPath',
                      fit: BoxFit.cover,
                    )
                  : const ColoredBox(color: Color(0x11000000)),
            ),
          ),
          const SizedBox(height: 12),

          // Chips tipo + nota
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (mediaType == 'movie' ? const Color(0xFFF28C18) : const Color(0xFF205295)).withOpacity(.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  (genreLabel != null && genreLabel!.isNotEmpty)
                      ? genreLabel!
                      : (mediaType == 'movie' ? 'Filme' : 'S�rie'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star_rate_rounded, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(rating.toStringAsFixed(1),
                      style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Título
          Text(title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.1)),
          const SizedBox(height: 8),

          // Overview
          if (overview.trim().isNotEmpty) ...[
            Text(overview, style: TextStyle(color: scheme.onSurface.withOpacity(.85))),
            const SizedBox(height: 24),
          ],

          // Botões também no corpo (opcional)
          FilledButton.icon(
            onPressed: () async {
              await WatchlistService.instance.addToWatchlist(
                tmdbId: tmdbId,
                mediaType: mediaType,
                title: title,
                posterPath: posterPath,
                overview: overview,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Adicionado à sua Lista ✅')),
                );
              }
            },
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Adicionar à Minha Lista'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _openScheduleSheet(
              context: context,
              tmdbId: tmdbId,
              mediaType: mediaType,
              title: title,
              posterPath: posterPath,
            ),
            icon: const Icon(Icons.event_available_outlined),
            label: const Text('Agendar sessão'),
          ),
        ],
      ),
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
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _ScheduleSheetDetails(
        tmdbId: tmdbId,
        mediaType: mediaType,
        title: title,
        posterPath: posterPath,
      ),
    );
  }
}

/// Versão local do sheet de agendamento (idêntica à que você já usa em DiscoverPage)
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
  DateTime _date = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay _time = TimeOfDay.now();
  final _seasonCtrl = TextEditingController();
  final _episodeCtrl = TextEditingController();
  final _countCtrl = TextEditingController(text: '1');
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _seasonCtrl.dispose();
    _episodeCtrl.dispose();
    _countCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final dt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final season = int.tryParse(_seasonCtrl.text);
    final episode = int.tryParse(_episodeCtrl.text);
    final count = int.tryParse(_countCtrl.text) ?? 1;

    await ScheduleService.instance.addSchedule(
      tmdbId: widget.tmdbId,
      mediaType: widget.mediaType,
      title: widget.title,
      posterPath: widget.posterPath,
      plannedAt: dt,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      season: season,
      episode: episode,
      episodesCount: count,
    );

    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sessão agendada ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 8,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text('Agendar: ${widget.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
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
                    label: Text('${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final t = await showTimePicker(context: context, initialTime: _time);
                      if (t != null) setState(() => _time = t);
                    },
                    icon: const Icon(Icons.schedule),
                    label: Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _seasonCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Temporada (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _episodeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Episódio (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _countCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantos episódios',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Anotações (opcional)',
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

