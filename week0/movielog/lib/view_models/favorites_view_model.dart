import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../core/session/session_guard.dart';
import '../core/utils/map_bounded.dart';
import '../core/utils/safe_notify.dart';
import '../data/models/favorite_list_item.dart';
import '../data/models/favorite_response_dto.dart';
import '../data/services/favorite_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'load_phase.dart';

class FavoritesViewModel extends ChangeNotifier with SafeNotify {
  FavoritesViewModel({
    required this.favoriteApi,
    required this.tmdbApi,
    required this.sessionGuard,
    required this.accountId,
    required this.onSessionExpired,
    this.enrichmentConcurrency = 5,
  });

  final FavoriteApiService favoriteApi;
  final TmdbMovieService tmdbApi;
  final SessionGuard sessionGuard;
  final String accountId;
  final Future<void> Function() onSessionExpired;
  final int enrichmentConcurrency;

  LoadPhase phase = LoadPhase.idle;
  List<FavoriteListItem> items = const [];
  String? errorMessage;
  int _refreshGeneration = 0;

  bool _isStale(int sessionGeneration, int refreshGeneration) =>
      isDisposed ||
      !sessionGuard.isCurrent(sessionGeneration, accountId) ||
      refreshGeneration != _refreshGeneration;

  bool _isSessionExpired(DioException error) {
    final code = apiErrorCode(error);
    return code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4';
  }

  Future<FavoriteListItem> _enrich(FavoriteResponseDto favorite) async {
    try {
      final movie = await tmdbApi.findMovieById(favorite.movieId);
      if (movie == null) {
        return FavoriteListItem(
          favorite: favorite,
          errorMessage: '영화 정보를 찾을 수 없습니다.',
        );
      }
      return FavoriteListItem(favorite: favorite, movie: movie);
    } catch (_) {
      return FavoriteListItem(
        favorite: favorite,
        errorMessage: '영화 정보를 불러오지 못했습니다.',
      );
    }
  }

  // 즐겨찾기를 다시 조회하고 TMDB 영화 정보를 최대 5개씩 보충
  // silent이면 이미 보이는 목록을 지우지 않고 갱신
  Future<void> refresh({bool silent = false}) async {
    final sessionGeneration = sessionGuard.generation;
    if (isDisposed || !sessionGuard.isCurrent(sessionGeneration, accountId)) {
      return;
    }

    final refreshGeneration = ++_refreshGeneration;
    final keepList =
        silent && (phase == LoadPhase.ready || phase == LoadPhase.empty);
    if (!keepList) {
      phase = LoadPhase.loading;
      errorMessage = null;
      notifyIfAlive();
    }

    try {
      final favorites = await favoriteApi.fetchMyFavorites();
      if (_isStale(sessionGeneration, refreshGeneration)) return;

      final enriched = await mapBounded(
        favorites,
        enrichmentConcurrency,
        _enrich,
      );
      if (_isStale(sessionGeneration, refreshGeneration)) return;

      items = enriched;
      phase = items.isEmpty ? LoadPhase.empty : LoadPhase.ready;
      errorMessage = null;
    } on DioException catch (error) {
      if (_isStale(sessionGeneration, refreshGeneration)) return;
      if (_isSessionExpired(error)) {
        await onSessionExpired();
        return;
      }
      if (!keepList) {
        phase = LoadPhase.error;
        errorMessage = '즐겨찾기를 불러오지 못했습니다.';
      }
    } catch (_) {
      if (_isStale(sessionGeneration, refreshGeneration)) return;
      if (!keepList) {
        phase = LoadPhase.error;
        errorMessage = '즐겨찾기를 불러오지 못했습니다.';
      }
    } finally {
      if (!_isStale(sessionGeneration, refreshGeneration)) notifyIfAlive();
    }
  }

  // 영화 정보를 못 가져온 카드 한 장만 다시 조회
  Future<void> retryItem(int movieId) async {
    final sessionGeneration = sessionGuard.generation;
    final refreshGeneration = _refreshGeneration;
    final target = items.where((item) => item.favorite.movieId == movieId);
    if (target.isEmpty) return;

    final updated = await _enrich(target.first.favorite);
    if (_isStale(sessionGeneration, refreshGeneration)) return;

    items = [
      for (final item in items)
        if (item.favorite.movieId == movieId) updated else item,
    ];
    notifyIfAlive();
  }
}
