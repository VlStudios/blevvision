import 'package:flutter/material.dart';

import '../discover/presentation/discover_page.dart';
import '../history/history_reports_page.dart';
import '../profile/profile_page.dart';
import '../schedule/schedule_page.dart';
import '../watchlist/watchlist_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int index = 0;
  int _historyVersion = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DiscoverPage(),
      const WatchlistPage(),
      const SchedulePage(),
      HistoryReportsPage(key: ValueKey(_historyVersion)),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() {
            index = i;
            if (i == 3) _historyVersion++;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.bookmark), label: 'Lista'),
          NavigationDestination(icon: Icon(Icons.event_note), label: 'Agenda'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Dados'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
