import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_dto.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'auth_view_model.dart';

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._ratingService, this._auth)
    : _sessionVersion = _auth.sessionVersion {
    _auth.addListener(_onAuthChanged);
  }

  final RatingApiService _ratingService;
  final AuthViewModel _auth;

  int _sessionVersion;
  bool _disposed = false;
  List<RatingWithMovie> _ratings = const [];

  List<RatingWithMovie> get ratings => _ratings;

  bool _isStale(int version) => _disposed || version != _auth.sessionVersion;

  // 로그아웃·만료·다른 계정 로그인으로 세션이 바뀌면 이전 평점 목록을 비웁니다.
  void _onAuthChanged() {
    if (_auth.sessionVersion == _sessionVersion) return;
    _sessionVersion = _auth.sessionVersion;
    if (_ratings.isNotEmpty) {
      _ratings = const [];
      _notify();
    }
  }

  // 등록 응답으로 받은 평점을 현재 세션 목록 맨 앞에 추가합니다.
  void addRating(RatingDto rating, TmdbMovieDto? movie) {
    if (_disposed) return;
    _ratings = [RatingWithMovie(rating: rating, movie: movie), ..._ratings];
    _notify();
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final version = _auth.sessionVersion;
    try {
      final updated = await _ratingService.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      if (_isStale(version)) {
        throw StateError('로그인 상태가 바뀌어 결과를 반영하지 않았어요.');
      }
      _ratings = [
        for (final entry in _ratings)
          if (entry.rating.ratingId == ratingId)
            RatingWithMovie(rating: updated, movie: entry.movie)
          else
            entry,
      ];
      _notify();
    } on DioException catch (error) {
      if (_isStale(version)) {
        throw StateError('로그인 상태가 바뀌어 결과를 반영하지 않았어요.');
      }
      throw await _toStateError(error, ratingId: ratingId);
    }
  }

  Future<void> deleteRating(int ratingId) async {
    final version = _auth.sessionVersion;
    try {
      await _ratingService.deleteRating(ratingId);
      if (_isStale(version)) {
        throw StateError('로그인 상태가 바뀌어 결과를 반영하지 않았어요.');
      }
      _remove(ratingId);
    } on DioException catch (error) {
      if (_isStale(version)) {
        throw StateError('로그인 상태가 바뀌어 결과를 반영하지 않았어요.');
      }
      throw await _toStateError(error, ratingId: ratingId);
    }
  }

  void _remove(int ratingId) {
    _ratings = [
      for (final entry in _ratings)
        if (entry.rating.ratingId != ratingId) entry,
    ];
    _notify();
  }

  // 401은 세션을 정리하고, 403·409·400은 안내만 합니다(로그아웃하지 않음).
  Future<StateError> _toStateError(
    DioException error, {
    required int ratingId,
  }) async {
    final code = apiErrorCode(error);
    if (code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4') {
      await _auth.expireSession();
      return StateError('로그인이 만료됐어요. 다시 로그인해 주세요.');
    }
    // 서버에 이미 없는 평점이면 화면 목록에서도 지워 서버 상태와 맞춥니다.
    if (code == 'RATING404_1') _remove(ratingId);
    return StateError(apiErrorMessage(error) ?? '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.');
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
