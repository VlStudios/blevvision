// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/hive/settings_box.dart';

import 'core/db/app_db.dart';
import 'core/auth/auth_gate.dart';
import 'features/onboarding/onboarding_page.dart';

// >>> ADICIONE:
import 'core/env/app_env.dart'; // AppEnv (Remote Config)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2) Hive & Drift
  await Hive.initFlutter();
  await SettingsBox.init();
  await AppDatabase.instance.ensureOpen();

  // 3) Remote Config (PRECISA estar pronto antes das telas usarem TmdbClient)
  await AppEnv().init();

  // 4) Sobe o app
  final startOnboarding = !SettingsBox.seenOnboarding;
  runApp(BlevVisionApp(startOnboarding: startOnboarding));
}

class BlevVisionApp extends StatelessWidget {
  const BlevVisionApp({super.key, required this.startOnboarding});
  final bool startOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlevVision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: startOnboarding ? const OnboardingPage() : const AuthGate(),
    );
  }
}
