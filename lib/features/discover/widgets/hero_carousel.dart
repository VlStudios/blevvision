import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    super.key,
    required this.items,
    this.onTapItem,
  });

  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic> item)? onTapItem;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _ctrl = PageController(viewportFraction: .92);
  int _index = 0;
  Timer? _auto;

  static const _imgBase = 'https://image.tmdb.org/t/p/w780';

  @override
  void initState() {
    super.initState();
    _auto = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_ctrl.hasClients || widget.items.isEmpty) return;
      final next = (_index + 1) % widget.items.length;
      _ctrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _auto?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 210,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: widget.items.length,
              itemBuilder: (_, i) {
                final m = widget.items[i];
                final path = (m['backdrop_path'] ??
                        m['poster_path'] ??
                        '/x6fKf2FzQbYyO9GdJrLqz1X0YcX.jpg') as String?;
                final title = (m['title'] ?? m['name'] ?? '') as String;
                final genreLabel = (m['genre_label'] ?? '').toString();
                final typeLabel = (m['type_label'] ?? '').toString();
                final tag = genreLabel.isNotEmpty ? genreLabel : typeLabel;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // imagem de fundo
                        CachedNetworkImage(
                          imageUrl: '$_imgBase$path',
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.black26,
                            child: const Center(
                              child: Icon(Icons.movie_creation_outlined,
                                  color: Colors.white60, size: 40),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.black26,
                            child: const Center(
                              child: Icon(Icons.broken_image_outlined,
                                  color: Colors.white60, size: 40),
                            ),
                          ),
                        ),

                        // gradiente lateral + inferior (cinematográfico)
                        IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withOpacity(.55),
                                  Colors.transparent,
                                  Colors.black.withOpacity(.35),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(.55),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // tipo (Filme/Série)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: scheme.primary.withOpacity(.9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              tag.isEmpty ? 'Título' : tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .3,
                              ),
                            ),
                          ),
                        ),

                        // título
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 18,
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                    blurRadius: 8,
                                    color: Colors.black54,
                                    offset: Offset(0, 1))
                              ],
                            ),
                          ),
                        ),

                        // toque abre detalhes
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onTapItem == null
                                ? null
                                : () => widget.onTapItem!(m),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // indicadores
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.items.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: i == _index ? 22 : 7,
                decoration: BoxDecoration(
                  color: i == _index
                      ? scheme.primary
                      : scheme.onSurface.withOpacity(.25),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
