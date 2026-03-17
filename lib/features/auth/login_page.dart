import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => loading = true);

      final google = GoogleSignIn();
      // Opcional: descomente se quiser sempre forçar escolha de conta
      // await google.signOut();

      final acc = await google.signIn();
      if (acc == null) return; // cancelado

      final auth = await acc.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: auth.accessToken, idToken: auth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(cred);

      // ⚠️ Sem sync aqui. O AuthGate fará o pull/listen após login.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no login: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.play_circle_fill, size: 72, color: AppTheme.brandOrange),
              const SizedBox(height: 12),
              const Text('BlevVision',
                style: TextStyle(color: AppTheme.brandBlue, fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 20, offset: Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Entrar ou criar conta',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.brandBlue, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: loading ? null : _signInWithGoogle,
                          icon: Image.asset('assets/icons/google.png', width: 22, height: 22),
                          label: Text(loading ? 'Entrando…' : 'Continuar com Google',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Ao continuar, você concorda com nossos Termos e Política de Privacidade.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
