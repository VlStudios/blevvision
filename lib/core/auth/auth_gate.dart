// lib/core/auth/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/shell/shell_page.dart';
import '../../features/auth/login_page.dart';
import '../../core/remote/firestore_sync.dart'; // <— seu FirestoreSync

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snap) {
        // Ainda conectando ao Firebase Auth
        if (snap.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }

        final user = snap.data;
        // Não logado -> Login
        if (user == null) return const LoginPage();

        // Logado -> roda sync uma vez e entra no app
        return const _PostLoginSync();
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Roda o pull inicial + listen remoto apenas UMA vez, com overlay de progresso.
/// Se falhar, avisa e segue pro app (não quebra a execução do Dart).
class _PostLoginSync extends StatefulWidget {
  const _PostLoginSync();

  @override
  State<_PostLoginSync> createState() => _PostLoginSyncState();
}

class _PostLoginSyncState extends State<_PostLoginSync> {
  bool _syncing = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    _runSync();
  }

  Future<void> _runSync() async {
    try {
      // Garante: só roda APÓS login. Aqui o Firebase já está inicializado.
      await FirestoreSync.instance.initialPull();
      FirestoreSync.instance.listenRemote();
    } catch (e) {
      _err = 'Falha ao sincronizar: $e';
    } finally {
      if (!mounted) return;
      setState(() => _syncing = false);

      if (_err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_err!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // App principal
        const ShellPage(),

        // Overlay de carregamento no primeiro pull
        if (_syncing)
          ColoredBox(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Sincronizando seus dados…',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
