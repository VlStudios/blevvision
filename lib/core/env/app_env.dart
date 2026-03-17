import 'package:firebase_remote_config/firebase_remote_config.dart';

class AppEnv {
  static final AppEnv _i = AppEnv._();
  AppEnv._();
  factory AppEnv() => _i;

  FirebaseRemoteConfig? _rc;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return; // idempotente
    final rc = FirebaseRemoteConfig.instance;

    await rc.setDefaults(const {
      'tmdb_api_key': '',
      'tmdb_base_url': 'https://api.themoviedb.org/3',
      'use_proxy': false,
      'function_base_url': '',
    });

    await rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 6),
    ));

    await rc.fetchAndActivate();

    _rc = rc;
    _ready = true;
  }

  void _assertReady() {
    if (!_ready || _rc == null) {
      throw StateError(
        'AppEnv não inicializado. Chame `await AppEnv().init()` antes de usar.',
      );
    }
  }

  // Fallback: permite injetar a chave via --dart-define=TMDB_API_KEY=xxxx
  static const _tmdbKeyDefine = String.fromEnvironment('TMDB_API_KEY');

  String get tmdbKey {
    _assertReady();
    final v = _rc!.getString('tmdb_api_key');
    return v.isNotEmpty ? v : _tmdbKeyDefine;
  }

  String get tmdbBaseUrl {
    _assertReady();
    return _rc!.getString('tmdb_base_url');
  }

  bool get useProxy {
    _assertReady();
    return _rc!.getBool('use_proxy');
  }

  String get functionBaseUrl {
    _assertReady();
    return _rc!.getString('function_base_url');
  }
}
