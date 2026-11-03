import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/member_service.dart';
import '../data/services/tmdb_movie_service.dart';

const int sampleMemberId = 1;

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._memberService, this._movieService, this.memberId);

  final MemberService _memberService;
  final TmdbMovieService _movieService;
  final int memberId;

  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;

  bool _isStale(int version) => _disposed || version != _requestVersion;

  Future<void> load() async {
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final rawRatings = await _memberService.fetchRatings(memberId);
      if (_isStale(version)) return;

      final movieIds = rawRatings
          .map((rating) => rating.movieId)
          .toSet()
          .where((id) => !_movieCache.containsKey(id));
      await Future.wait(movieIds.map(_loadMovie));
      if (_isStale(version)) return;

      final entries = [
        for (final rating in rawRatings)
          RatingWithMovie(rating: rating, movie: _movieCache[rating.movieId]),
      ];
      final missingMovies = entries.where((entry) => entry.movie == null);

      ratings = entries;
      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;
      if (missingMovies.isNotEmpty) {
        message = '일부 영화 정보를 가져오지 못해 제목·포스터를 대신 표시합니다.';
      }
    } on DioException catch (error) {
      if (_isStale(version)) return;
      status = MyRatingsLoadStatus.error;
      message = _errorMessage(error);
    } catch (_) {
      if (_isStale(version)) return;
      status = MyRatingsLoadStatus.error;
      message = '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
    }

    notifyListeners();
  }

  Future<void> _loadMovie(int movieId) async {
    try {
      _movieCache[movieId] = await _movieService.findMovieById(movieId);
    } on DioException {
      // 일시적 통신 실패는 캐시하지 않아서 다음 로딩에서 다시 시도하도록
    }
  }

  String _errorMessage(DioException error) {
    final status = error.response?.statusCode;
    if (status == 400) return 'memberId 형식을 다시 확인해 주세요.';
    if (status == 404) return '존재하지 않는 회원입니다.';
    return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
