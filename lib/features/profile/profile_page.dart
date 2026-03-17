import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../core/db/app_db.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Center(
            child: Column(
              children: [
                if (user?.photoURL != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoURL!),
                    radius: 42,
                  )
                else
                  const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 32)),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'Usuario',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ActionCard(
            icon: Icons.cleaning_services_outlined,
            title: 'Limpar cache',
            subtitle:
                'Remove imagens e arquivos temporarios do app. Nao apaga agenda, progresso nem lista.',
            buttonLabel: 'Limpar cache',
            busy: _busy,
            onPressed: _clearCache,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.delete_sweep_outlined,
            title: 'Limpar dados',
            subtitle:
                'Apaga agenda, historico, progresso, watchlist e dados locais da aplicacao. Essa acao nao pode ser desfeita.',
            buttonLabel: 'Limpar dados',
            destructive: true,
            busy: _busy,
            onPressed: _clearData,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.logout,
            title: 'Sair da conta',
            subtitle: 'Encerra a sessao atual neste aparelho.',
            buttonLabel: 'Sair',
            busy: _busy,
            onPressed: _signOut,
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    final ok = await _confirm(
      title: 'Limpar cache?',
      message:
          'Isso remove imagens e arquivos temporarios do app. Seus agendamentos, lista e progressos continuam salvos.',
      confirmLabel: 'Limpar',
    );
    if (!ok || !mounted) return;

    setState(() => _busy = true);
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache limpo com sucesso')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearData() async {
    final ok = await _confirm(
      title: 'Limpar todos os dados?',
      message:
          'Isso apaga agenda, progressos, historicos e watchlist salvos neste aparelho. Essa acao nao pode ser desfeita.',
      confirmLabel: 'Apagar tudo',
      destructive: true,
    );
    if (!ok || !mounted) return;

    setState(() => _busy = true);
    try {
      await AppDatabase.instance.clearAllUserData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados locais apagados')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    this.destructive = false,
    this.busy = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool destructive;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = destructive ? scheme.error : scheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(subtitle),
            const SizedBox(height: 14),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: scheme.onError,
                    )
                  : null,
              onPressed: busy ? null : onPressed,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
