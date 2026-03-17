import 'package:hive_flutter/hive_flutter.dart';

class SettingsBox {
  static const _box = 'settings';
  static const _kSeenOnboarding = 'seen_onboarding';
  static late Box _b;

  static Future<void> init() async => _b = await Hive.openBox(_box);

  static bool get seenOnboarding =>
      _b.get(_kSeenOnboarding, defaultValue: false) as bool;

  static Future<void> setSeenOnboarding() =>
      _b.put(_kSeenOnboarding, true);
}
