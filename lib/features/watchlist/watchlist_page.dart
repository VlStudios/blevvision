import 'package:flutter/material.dart';
import '../../../core/db/app_db.dart';              // MediaItem, WatchlistData
import '../../../core/db/watchlist_service.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = WatchlistService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Watchlist')),
      body: StreamBuilder<List<(WatchlistData, MediaItem)>>(
        stream: service.watchWatchlist(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          }

          final items = snap.data ?? const <(WatchlistData, MediaItem)>[];
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum item salvo ainda.'));
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final (w, media) = items[i]; // w=WatchlistData, media=MediaItem
              return ListTile(
                leading: media.posterPath != null && media.posterPath!.isNotEmpty
                    ? Image.network(
                        "https://image.tmdb.org/t/p/w92${media.posterPath!}",
                        width: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.movie),
                title: Text(media.title),
                subtitle: Text(media.mediaType.toUpperCase()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await WatchlistService.instance.removeFromWatchlist(
                      tmdbId: media.tmdbId,
                      mediaType: media.mediaType,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
