import 'package:dio/dio.dart';
import '../../core/env/app_env.dart';

class TmdbClient {
  late final Dio _dio;

  TmdbClient() {
    final key = AppEnv().tmdbKey;
    if (key.isEmpty) {
      throw StateError(
        'tmdb_api_key não configurado. Defina no Remote Config '
        'ou rode com --dart-define=TMDB_API_KEY=SUACHAVE',
      );
    }
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnv().tmdbBaseUrl, // ex: https://api.themoviedb.org/3
        queryParameters: {
          'api_key': key,
          'language': 'pt-BR',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }

  // ========= Helpers =========

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final r = await _dio.get(path, queryParameters: params);
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ========= Trending / Search =========

  Future<Map<String, dynamic>> trendingAllWeek({int page = 1}) =>
      _get('/trending/all/week', params: {'page': page});

  Future<Map<String, dynamic>> trendingMovieWeek({int page = 1}) =>
      _get('/trending/movie/week', params: {'page': page});

  Future<Map<String, dynamic>> trendingTvWeek({int page = 1}) =>
      _get('/trending/tv/week', params: {'page': page});

  Future<Map<String, dynamic>> searchMulti(String q, {int page = 1}) =>
      _get('/search/multi', params: {
        'query': q,
        'page': page,
        'include_adult': false,
      });

  Future<Map<String, dynamic>> movieGenres() => _get('/genre/movie/list');

  Future<Map<String, dynamic>> tvGenres() => _get('/genre/tv/list');

  // ========= Details =========

  /// Detalhes de série (contém next_episode_to_air quando existir)
  Future<Map<String, dynamic>> tvDetails(int id) => _get('/tv/$id');

  /// Detalhes de filme
  Future<Map<String, dynamic>> movieDetails(int id) => _get('/movie/$id');

  /// Episódios de uma temporada
  Future<Map<String, dynamic>> tvSeason(int id, int seasonNumber) =>
      _get('/tv/$id/season/$seasonNumber');

  // ========= Discover (genéricos) =========

  /// Discover TV genérico: use para montar consultas customizadas
  /// Exemplos de params:
  ///  - with_origin_country: 'KR,JP'
  ///  - with_genres: '18' (Drama)
  ///  - with_original_language: 'ko'
  ///  - first_air_date_year: 2024
  ///  - sort_by: 'popularity.desc'
  Future<Map<String, dynamic>> discoverTv({
    int page = 1,
    String sortBy = 'popularity.desc',
    String? withGenres,
    String? withOriginCountry,
    String? withOriginalLanguage,
    bool includeAdult = false,
    String? firstAirDateYear,
  }) {
    final params = <String, dynamic>{
      'page': page,
      'sort_by': sortBy,
      'include_adult': includeAdult,
    };

    if (withGenres != null && withGenres.isNotEmpty) {
      params['with_genres'] = withGenres;
    }
    if (withOriginCountry != null && withOriginCountry.isNotEmpty) {
      params['with_origin_country'] = withOriginCountry;
    }
    if (withOriginalLanguage != null && withOriginalLanguage.isNotEmpty) {
      params['with_original_language'] = withOriginalLanguage;
    }
    if (firstAirDateYear != null && firstAirDateYear.isNotEmpty) {
      params['first_air_date_year'] = firstAirDateYear;
    }

    return _get('/discover/tv', params: params);
  }

  /// Discover Movies genérico (se precisar no futuro)
  Future<Map<String, dynamic>> discoverMovie({
    int page = 1,
    String sortBy = 'popularity.desc',
    String? withGenres,
    String? withOriginCountry,
    String? withOriginalLanguage,
    bool includeAdult = true,
    String? primaryReleaseYear,
  }) {
    final params = <String, dynamic>{
      'page': page,
      'sort_by': sortBy,
      'include_adult': includeAdult,
    };

    if (withGenres != null && withGenres.isNotEmpty) {
      params['with_genres'] = withGenres;
    }
    if (withOriginCountry != null && withOriginCountry.isNotEmpty) {
      params['with_origin_country'] = withOriginCountry;
    }
    if (withOriginalLanguage != null && withOriginalLanguage.isNotEmpty) {
      params['with_original_language'] = withOriginalLanguage;
    }
    if (primaryReleaseYear != null && primaryReleaseYear.isNotEmpty) {
      params['primary_release_year'] = primaryReleaseYear;
    }

    return _get('/discover/movie', params: params);
  }

  // ========= Doramas =========

  /// Doramas (K/J/C/TW/HK) via Discover TV.
  /// Usa países de origem para trazer títulos locais (melhor cobertura que filtrar só por língua).
  /// Se quiser forçar apenas "Drama", passe [onlyDramaGenre] = true.
  Future<Map<String, dynamic>> discoverDoramas({
    int page = 1,
    bool onlyDramaGenre = true,
    String sortBy = 'popularity.desc',
  }) {
    return discoverTv(
      page: page,
      sortBy: sortBy,
      withOriginCountry: 'KR,JP,CN,TW,HK',
      withGenres: onlyDramaGenre ? '18' : null, // 18 = Drama
      includeAdult: true,
    );
  }

  /// Animes (séries japonesas de animação) via Discover TV.
  Future<Map<String, dynamic>> discoverAnime({
    int page = 1,
    String sortBy = 'popularity.desc',
  }) {
    return discoverTv(
      page: page,
      sortBy: sortBy,
      withOriginCountry: 'JP',
      withGenres: '16', // 16 = Animation
      includeAdult: false,
    );
  }
}
