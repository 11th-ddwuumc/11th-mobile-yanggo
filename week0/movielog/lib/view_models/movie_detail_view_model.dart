import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'auth_view_model.dart';
import 'my_ratings_view_model.dart';
import 'sign_up_view_model.dart' show SubmitStatus;

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(
    this._ratingService,
    this._auth,
    this._myRatings,
    this.movie,
  );

  final RatingApiService _ratingService;
  final AuthViewModel _auth;
  final MyRatingsViewModel _myRatings;
  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  bool _isStale(int version) => _disposed || version != _auth.sessionVersion;

  Future<void> createRating({required int score, String? comment}) async {
    if (submitStatus == SubmitStatus.submitting) return;

    final version = _auth.sessionVersion;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    _notify();

    try {
      // movieId는 TMDB 영화 id(TmdbMovieDto.id)입니다. memberId는 보내지 않습니다.
      final rating = await _ratingService.createRating(
        CreateRatingRequest(movieId: movie.id, score: score, comment: comment),
      );
      if (_isStale(version)) return;
      _myRatings.addRating(rating, movie);
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_isStale(version)) return;
      submitStatus = SubmitStatus.error;
      final code = apiErrorCode(error);
      if (code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4') {
        submitMessage = '로그인이 만료됐어요. 다시 로그인해 주세요.';
        await _auth.expireSession();
      } else {
        submitMessage =
            apiErrorMessage(error) ?? '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
      }
    } on StateError catch (error) {
      if (_isStale(version)) return;
      submitStatus = SubmitStatus.error;
      submitMessage = error.message;
    }

    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
