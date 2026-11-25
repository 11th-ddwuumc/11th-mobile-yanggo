import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../core/session/session_guard.dart';
import '../core/utils/safe_notify.dart';
import '../data/services/favorite_api_service.dart';

class FavoriteDetailViewModel extends ChangeNotifier with SafeNotify {
  FavoriteDetailViewModel({
    required this.movieId,
    required this.favoriteApi,
    required this.sessionGuard,
    required this.accountId,
    required this.onSessionExpired,
  });

  // 상세 화면의 TMDB 영화 ID. 즐겨찾기 경로에는 favoriteId가 아니라 이 값을 씁니다.
  final int movieId;
  final FavoriteApiService favoriteApi;
  final SessionGuard sessionGuard;
  final String accountId;
  final Future<void> Function() onSessionExpired;

  bool isFavorite = false;
  bool hasLoadedStatus = false;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  bool _isStale(int generation) =>
      isDisposed || !sessionGuard.isCurrent(generation, accountId);

  bool _isSessionExpired(DioException error) {
    final code = apiErrorCode(error);
    return code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4';
  }

  Future<void> load() async {
    if (isLoading || isSaving) return;
    final generation = sessionGuard.generation;
    if (_isStale(generation)) return;

    isLoading = true;
    errorMessage = null;
    notifyIfAlive();
    try {
      final result = await favoriteApi.checkFavorite(movieId: movieId);
      if (_isStale(generation)) return;
      isFavorite = result.isFavorite;
      hasLoadedStatus = true;
    } on DioException catch (error) {
      if (_isStale(generation)) return;
      if (_isSessionExpired(error)) {
        await onSessionExpired();
        return;
      }
      errorMessage = '즐겨찾기 여부를 확인하지 못했습니다.';
    } catch (_) {
      if (_isStale(generation)) return;
      errorMessage = '즐겨찾기 여부를 확인하지 못했습니다.';
    } finally {
      if (!_isStale(generation)) {
        isLoading = false;
        notifyIfAlive();
      }
    }
  }

  Future<void> toggle() async {
    if (isSaving || isLoading || !hasLoadedStatus) return;
    final generation = sessionGuard.generation;
    if (_isStale(generation)) return;

    final before = isFavorite;
    isSaving = true;
    errorMessage = null;
    notifyIfAlive();
    try {
      if (before) {
        await favoriteApi.deleteFavorite(movieId: movieId);
        if (_isStale(generation)) return;
        isFavorite = false;
      } else {
        await favoriteApi.addFavorite(movieId: movieId);
        if (_isStale(generation)) return;
        isFavorite = true;
      }
    } on DioException catch (error) {
      if (_isStale(generation)) return;
      if (_isSessionExpired(error)) {
        await onSessionExpired();
        return;
      }
      final code = apiErrorCode(error);
      if (code == 'FAVORITE409_1' || code == 'FAVORITE404_1') {
        // 이미 등록/이미 해제: 서버의 현재 상태로 화면을 맞춥니다.
        try {
          final synced = await favoriteApi.checkFavorite(movieId: movieId);
          if (_isStale(generation)) return;
          isFavorite = synced.isFavorite;
        } catch (_) {
          if (_isStale(generation)) return;
          isFavorite = before;
          errorMessage = '서버 상태를 다시 확인하지 못했습니다.';
        }
      } else {
        isFavorite = before;
        errorMessage = '저장하지 못했습니다. 다시 시도해 주세요.';
      }
    } catch (_) {
      if (_isStale(generation)) return;
      isFavorite = before;
      errorMessage = '저장하지 못했습니다. 다시 시도해 주세요.';
    } finally {
      if (!_isStale(generation)) {
        isSaving = false;
        notifyIfAlive();
      }
    }
  }
}
