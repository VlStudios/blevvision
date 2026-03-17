import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/db/app_db.dart';
import '../schedule/schedule_page.dart';
import '../../theme/app_theme.dart';

class HistoryReportsPage extends StatefulWidget {
  const HistoryReportsPage({super.key});

  @override
  State<HistoryReportsPage> createState() => _HistoryReportsPageState();
}

class _HistoryReportsPageState extends State<HistoryReportsPage> {
  static const _imgBase = 'https://image.tmdb.org/t/p/w185';
  final _db = AppDatabase.instance;
  late Future<_HistoryReportsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HistoryReportsData> _load() async {
    final watchlistCount = await _countTable('watchlist');
    final scheduleCount = await _countTable('schedule_items');

    final recentSchedulesQuery = (_db.select(_db.scheduleItems)
          ..orderBy([(s) => drift.OrderingTerm.desc(s.createdAt)])
          ..limit(8))
        .join([
      drift.innerJoin(_db.mediaItems, _db.mediaItems.id.equalsExp(_db.scheduleItems.mediaId)),
    ]);

    final recentSchedules = await recentSchedulesQuery.get().then(
          (rows) => rows
              .map(
                (r) => _RecentScheduleRow(
                  schedule: r.readTable(_db.scheduleItems),
                  media: r.readTable(_db.mediaItems),
                ),
              )
              .toList(),
        );

    final recentProgressQuery = (_db.select(_db.progress)
          ..orderBy([(p) => drift.OrderingTerm.desc(p.updatedAt)]))
        .join([
      drift.innerJoin(_db.mediaItems, _db.mediaItems.id.equalsExp(_db.progress.mediaId)),
    ]);

    final recentProgress = await recentProgressQuery.get().then(
          (rows) => rows
              .map(
                (r) => _RecentProgressRow(
                  progress: r.readTable(_db.progress),
                  media: r.readTable(_db.mediaItems),
                ),
              )
              .toList(),
        );

    final dedupedRecentProgress = <String, _RecentProgressRow>{};
    for (final row in recentProgress) {
      final key =
          '${row.media.id}:${row.progress.season ?? '-'}:${row.progress.episode ?? '-'}';
      dedupedRecentProgress.putIfAbsent(key, () => row);
    }

    final recentProgressList = dedupedRecentProgress.values.take(8).toList();

    final allProgressRows = await _db.select(_db.progress).get();
    final progressByKey = <String, ProgressData>{};
    for (final row in allProgressRows) {
      final key = '${row.mediaId}:${row.season ?? '-'}:${row.episode ?? '-'}';
      final current = progressByKey[key];
      if (current == null ||
          row.updatedAt.isAfter(current.updatedAt) ||
          (row.updatedAt.isAtSameMomentAs(current.updatedAt) && row.id > current.id)) {
        progressByKey[key] = row;
      }
    }

    final progressCount = progressByKey.length;
    final completedCount = progressByKey.values.where((p) => p.completed).length;

    return _HistoryReportsData(
      watchlistCount: watchlistCount,
      scheduleCount: scheduleCount,
      progressCount: progressCount,
      completedCount: completedCount,
      recentSchedules: recentSchedules,
      recentProgress: recentProgressList,
    );
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historicos e Relatorios')),
      body: FutureBuilder<_HistoryReportsData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'Falha ao carregar dados desta tela.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refresh,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snap.data!;
          final reportCards = [
            _ReportCardData(
              type: _ReportType.watchlist,
              label: 'Na Lista',
              value: data.watchlistCount,
              icon: Icons.bookmark_outline,
            ),
            _ReportCardData(
              type: _ReportType.scheduled,
              label: 'Agendados',
              value: data.scheduleCount,
              icon: Icons.event_note_outlined,
            ),
            _ReportCardData(
              type: _ReportType.progress,
              label: 'Progressos',
              value: data.progressCount,
              icon: Icons.play_circle_outline,
            ),
            _ReportCardData(
              type: _ReportType.completed,
              label: 'Concluidos',
              value: data.completedCount,
              icon: Icons.check_circle_outline,
            ),
          ];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                const _SectionTitle('Relatorios'),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final compact = width < 360;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        mainAxisExtent: compact ? 118 : 108,
                      ),
                      itemBuilder: (context, index) {
                        final item = reportCards[index];
                        return _StatCard(
                          label: item.label,
                          value: item.value,
                          icon: item.icon,
                          compact: compact,
                          onTap: () => Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => _ReportDetailsPage(type: item.type),
                                ),
                              )
                              .then((_) => _refresh()),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 18),
                const _SectionTitle('Historico de progresso'),
                const SizedBox(height: 8),
                if (data.recentProgress.isEmpty)
                  const _EmptyCard(message: 'Nenhum progresso salvo ainda.')
                else
                  ...data.recentProgress.map(_buildProgressCard),
                const SizedBox(height: 18),
                const _SectionTitle('Historico de agendamentos'),
                const SizedBox(height: 8),
                if (data.recentSchedules.isEmpty)
                  const _EmptyCard(message: 'Nenhum agendamento encontrado.')
                else
                  ...data.recentSchedules.map(_buildScheduleCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<int> _countTable(String tableName) async {
    final row = await _db.customSelect(
      'SELECT COUNT(*) AS c FROM $tableName',
    ).getSingle();
    return row.read<int>('c') ?? 0;
  }

  Widget _buildProgressCard(_RecentProgressRow row) {
    final progress = row.progress;
    final media = row.media;
    final subtitle = _progressSubtitle(progress);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => _HistoryEntryDetailsPage(
                  title: media.title,
                  posterPath: media.posterPath,
                  subtitle: subtitle,
                  dateLabel: 'Atualizado em ${_fmtDateTime(progress.updatedAt)}',
                ),
              ),
            )
            .then((_) => _refresh()),
        leading: _PosterThumb(posterPath: media.posterPath),
        title: Text(media.title),
        subtitle: Text('$subtitle\nAtualizado em ${_fmtDateTime(progress.updatedAt)}'),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Excluir progresso',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteProgressRow(row),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(_RecentScheduleRow row) {
    final schedule = row.schedule;
    final media = row.media;
    final se = [
      if (schedule.season != null) 'T${schedule.season}',
      if (schedule.episode != null) 'E${schedule.episode}',
    ].join('');

    final meta = [
      if (se.isNotEmpty) se,
      'Data ${_fmtDate(schedule.plannedAt)}',
    ].join('  ');

    final subtitle = '${media.mediaType == 'movie' ? 'Filme' : 'Serie'}  $meta';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => _HistoryEntryDetailsPage(
                  title: media.title,
                  posterPath: media.posterPath,
                  subtitle: subtitle,
                  dateLabel: 'Criado em ${_fmtDateTime(schedule.createdAt)}',
                ),
              ),
            )
            .then((_) => _refresh()),
        leading: _PosterThumb(posterPath: media.posterPath),
        title: Text(media.title),
        subtitle: Text('$subtitle\nCriado em ${_fmtDateTime(schedule.createdAt)}'),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar agendamento',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editScheduleRow(row),
            ),
            IconButton(
              tooltip: 'Excluir agendamento',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteScheduleRow(row),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProgressRow(_RecentProgressRow row) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir progresso?'),
        content: Text(
          'Voce vai remover o progresso salvo de "${row.media.title}".',
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
    await (_db.delete(_db.progress)..where((p) => p.id.equals(row.progress.id))).go();
    if (!mounted) return;
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progresso removido')),
    );
  }

  Future<void> _deleteScheduleRow(_RecentScheduleRow row) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir agendamento?'),
        content: Text(
          'Voce vai remover o agendamento salvo de "${row.media.title}".',
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
    await (_db.delete(_db.scheduleItems)..where((s) => s.id.equals(row.schedule.id))).go();
    if (!mounted) return;
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agendamento removido')),
    );
  }

  Future<void> _editScheduleRow(_RecentScheduleRow row) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScheduleEditPage(
          media: row.media,
          sched: row.schedule,
        ),
      ),
    );
    if (!mounted) return;
    await _refresh();
  }

  String _fmtDate(DateTime dt) {
    return '${_two(dt.day)}/${_two(dt.month)}/${dt.year}';
  }

  String _fmtDateTime(DateTime dt) {
    return '${_fmtDate(dt)} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  String _fmtHms(int totalSec) {
    final s = totalSec < 0 ? 0 : totalSec;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final ss = s % 60;
    return '${_two(h)}:${_two(m)}:${_two(ss)}';
  }

  String _progressSubtitle(ProgressData progress) {
    if (progress.season == null && progress.episode == null) {
      return 'Parou em ${_fmtHms(progress.positionSec)}';
    }
    return 'Parou na temporada ${progress.season ?? '-'}, episodio ${progress.episode ?? '-'}, em ${_fmtHms(progress.positionSec)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

class _PosterThumb extends StatelessWidget {
  const _PosterThumb({required this.posterPath});

  final String? posterPath;

  @override
  Widget build(BuildContext context) {
    final url = posterPath == null ? null : '${_HistoryReportsPageState._imgBase}$posterPath';
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 42,
        height: 60,
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.compact = false,
    this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.brandBlue.withValues(alpha: 0.10)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120D2B57),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 10 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: compact ? 30 : 34,
                      height: compact ? 30 : 34,
                      decoration: BoxDecoration(
                        color: AppTheme.brandBlue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: compact ? 18 : 20,
                        color: AppTheme.brandBlue,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: compact ? 16 : 18,
                      color: AppTheme.brandBlue.withValues(alpha: 0.72),
                    ),
                  ],
                ),
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: compact ? 22 : 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.brandBlue,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    color: const Color(0xFF4B5B76),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }
}

class _HistoryReportsData {
  const _HistoryReportsData({
    required this.watchlistCount,
    required this.scheduleCount,
    required this.progressCount,
    required this.completedCount,
    required this.recentSchedules,
    required this.recentProgress,
  });

  final int watchlistCount;
  final int scheduleCount;
  final int progressCount;
  final int completedCount;
  final List<_RecentScheduleRow> recentSchedules;
  final List<_RecentProgressRow> recentProgress;
}

class _RecentScheduleRow {
  const _RecentScheduleRow({
    required this.schedule,
    required this.media,
  });

  final ScheduleItem schedule;
  final MediaItem media;
}

class _RecentProgressRow {
  const _RecentProgressRow({
    required this.progress,
    required this.media,
  });

  final ProgressData progress;
  final MediaItem media;
}

class _ReportCardData {
  const _ReportCardData({
    required this.type,
    required this.label,
    required this.value,
    required this.icon,
  });

  final _ReportType type;
  final String label;
  final int value;
  final IconData icon;
}

enum _ReportType {
  watchlist,
  scheduled,
  progress,
  completed,
}

class _ReportDetailsPage extends StatefulWidget {
  const _ReportDetailsPage({required this.type});

  final _ReportType type;

  @override
  State<_ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<_ReportDetailsPage> {
  final _db = AppDatabase.instance;
  late Future<List<_ReportDetailItem>> _future;
  int? _selectedYear;
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _future = _loadItems();
  }

  Future<void> _refresh() async {
    final future = _loadItems();
    setState(() => _future = future);
    await future;
  }

  Future<List<_ReportDetailItem>> _loadItems() async {
    switch (widget.type) {
      case _ReportType.watchlist:
        final query = (_db.select(_db.watchlist)
              ..orderBy([(w) => drift.OrderingTerm.desc(w.addedAt)]))
            .join([
          drift.innerJoin(_db.mediaItems, _db.mediaItems.id.equalsExp(_db.watchlist.mediaId)),
        ]);
        final rows = await query.get();
        return rows
            .map(
              (r) => _ReportDetailItem(
                key: 'watchlist:${r.readTable(_db.mediaItems).id}:${r.readTable(_db.watchlist).id}',
                deleteType: _ReportDeleteType.watchlist,
                recordId: r.readTable(_db.watchlist).id,
                title: r.readTable(_db.mediaItems).title,
                posterPath: r.readTable(_db.mediaItems).posterPath,
                date: r.readTable(_db.watchlist).addedAt,
                subtitle: r.readTable(_db.mediaItems).mediaType == 'movie' ? 'Filme' : 'Serie',
              ),
            )
            .toList();
      case _ReportType.scheduled:
        final query = (_db.select(_db.scheduleItems)
              ..orderBy([(s) => drift.OrderingTerm.desc(s.createdAt)]))
            .join([
          drift.innerJoin(_db.mediaItems, _db.mediaItems.id.equalsExp(_db.scheduleItems.mediaId)),
        ]);
        final rows = await query.get();
        return rows
            .map((r) {
              final media = r.readTable(_db.mediaItems);
              final sched = r.readTable(_db.scheduleItems);
              final se = [
                if (sched.season != null) 'T${sched.season}',
                if (sched.episode != null) 'E${sched.episode}',
              ].join(' ');
              return _ReportDetailItem(
                key: 'schedule:${media.id}:${sched.id}',
                deleteType: _ReportDeleteType.schedule,
                recordId: sched.id,
                title: media.title,
                posterPath: media.posterPath,
                date: sched.createdAt,
                subtitle: [
                  if (se.isNotEmpty) se,
                  'Data ${_fmtDate(sched.plannedAt)}',
                ].join('  '),
              );
            })
            .toList();
      case _ReportType.progress:
      case _ReportType.completed:
        final query = (_db.select(_db.progress)
              ..orderBy([(p) => drift.OrderingTerm.desc(p.updatedAt)]))
            .join([
          drift.innerJoin(_db.mediaItems, _db.mediaItems.id.equalsExp(_db.progress.mediaId)),
        ]);
        final rows = await query.get();
        final filtered = widget.type == _ReportType.completed
            ? rows.where((r) => r.readTable(_db.progress).completed)
            : rows;
        final items = filtered
            .map((r) {
              final media = r.readTable(_db.mediaItems);
              final progress = r.readTable(_db.progress);
              return _ReportDetailItem(
                key:
                    '${media.id}:${progress.season ?? '-'}:${progress.episode ?? '-'}',
                deleteType: _ReportDeleteType.progress,
                recordId: progress.id,
                title: media.title,
                posterPath: media.posterPath,
                date: progress.updatedAt,
                subtitle: _progressSubtitle(progress),
              );
            })
            .toList();
        final deduped = <String, _ReportDetailItem>{};
        for (final item in items) {
          deduped.putIfAbsent(item.key, () => item);
        }
        return deduped.values.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleForType(widget.type))),
      body: FutureBuilder<List<_ReportDetailItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(child: Text('Falha ao carregar detalhes.'));
          }

          final items = snap.data ?? const [];
          final years = items.map((e) => e.date.year).toSet().toList()..sort((a, b) => b.compareTo(a));
          _selectedYear ??= years.isNotEmpty ? years.first : null;

          final months = items
              .where((e) => _selectedYear == null || e.date.year == _selectedYear)
              .map((e) => e.date.month)
              .toSet()
              .toList()
            ..sort();

          if (_selectedMonth != null && !months.contains(_selectedMonth)) {
            _selectedMonth = null;
          }

          final filtered = items.where((e) {
            final yearOk = _selectedYear == null || e.date.year == _selectedYear;
            final monthOk = _selectedMonth == null || e.date.month == _selectedMonth;
            return yearOk && monthOk;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: const InputDecoration(
                          labelText: 'Ano',
                          border: OutlineInputBorder(),
                        ),
                        items: years
                            .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedYear = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedMonth,
                        decoration: const InputDecoration(
                          labelText: 'Mes',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(value: null, child: Text('Todos')),
                          ...months.map((m) => DropdownMenuItem<int?>(value: m, child: Text(_monthName(m)))),
                        ],
                        onChanged: (v) => setState(() => _selectedMonth = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...filtered.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _HistoryEntryDetailsPage(
                            title: item.title,
                            posterPath: item.posterPath,
                            subtitle: item.subtitle,
                            dateLabel: _fmtDateTime(item.date),
                          ),
                        ),
                      ),
                      leading: _PosterThumb(posterPath: item.posterPath),
                      title: Text(item.title),
                      subtitle: Text('${item.subtitle}\n${_fmtDateTime(item.date)}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Excluir',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteItem(item),
                      ),
                    ),
                  )),
              if (filtered.isEmpty)
                const _EmptyCard(message: 'Nenhum item encontrado para esse filtro.'),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteItem(_ReportDetailItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir item?'),
        content: Text(
          'Voce vai excluir "${item.title}" desta lista de dados. Essa acao remove o registro salvo.',
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

    switch (item.deleteType) {
      case _ReportDeleteType.watchlist:
        await (_db.delete(_db.watchlist)..where((w) => w.id.equals(item.recordId))).go();
        break;
      case _ReportDeleteType.schedule:
        await (_db.delete(_db.scheduleItems)..where((s) => s.id.equals(item.recordId))).go();
        break;
      case _ReportDeleteType.progress:
        await (_db.delete(_db.progress)..where((p) => p.id.equals(item.recordId))).go();
        break;
    }

    if (!mounted) return;
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removido')),
    );
  }

  String _titleForType(_ReportType type) {
    switch (type) {
      case _ReportType.watchlist:
        return 'Detalhes da Lista';
      case _ReportType.scheduled:
        return 'Detalhes de Agendados';
      case _ReportType.progress:
        return 'Detalhes de Progressos';
      case _ReportType.completed:
        return 'Detalhes de Concluidos';
    }
  }

  String _monthName(int month) {
    const names = [
      '',
      'Janeiro',
      'Fevereiro',
      'Marco',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return names[month];
  }

  String _fmtDate(DateTime dt) {
    return '${_two(dt.day)}/${_two(dt.month)}/${dt.year}';
  }

  String _fmtDateTime(DateTime dt) {
    return '${_fmtDate(dt)} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  String _fmtHms(int totalSec) {
    final s = totalSec < 0 ? 0 : totalSec;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final ss = s % 60;
    return '${_two(h)}:${_two(m)}:${_two(ss)}';
  }

  String _progressSubtitle(ProgressData progress) {
    if (progress.season == null && progress.episode == null) {
      return 'Parou em ${_fmtHms(progress.positionSec)}';
    }
    return 'Parou na temporada ${progress.season ?? '-'}, episodio ${progress.episode ?? '-'}, em ${_fmtHms(progress.positionSec)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

class _ReportDetailItem {
  const _ReportDetailItem({
    required this.key,
    required this.deleteType,
    required this.recordId,
    required this.title,
    required this.posterPath,
    required this.date,
    required this.subtitle,
  });

  final String key;
  final _ReportDeleteType deleteType;
  final int recordId;
  final String title;
  final String? posterPath;
  final DateTime date;
  final String subtitle;
}

enum _ReportDeleteType {
  watchlist,
  schedule,
  progress,
}

class _HistoryEntryDetailsPage extends StatelessWidget {
  const _HistoryEntryDetailsPage({
    required this.title,
    required this.posterPath,
    required this.subtitle,
    required this.dateLabel,
  });

  final String title;
  final String? posterPath;
  final String subtitle;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PosterThumb(posterPath: posterPath),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.brandBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _DetailBlock(
            title: 'Informacoes',
            icon: Icons.info_outline,
            child: Text(subtitle),
          ),
          const SizedBox(height: 12),
          _DetailBlock(
            title: 'Data',
            icon: Icons.event_outlined,
            child: Text(dateLabel),
          ),
          const SizedBox(height: 12),
          _DetailBlock(
            title: 'Status',
            icon: Icons.analytics_outlined,
            child: Text(_statusText()),
          ),
        ],
      ),
    );
  }

  String _statusText() {
    if (subtitle.toLowerCase().contains('parou na temporada')) {
      return 'Progresso registrado';
    }
    if (subtitle.toLowerCase().contains('data ')) {
      return 'Agendamento registrado';
    }
    return 'Item registrado';
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.brandBlue.withValues(alpha: 0.10)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120D2B57),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.brandBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.brandBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.brandBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
