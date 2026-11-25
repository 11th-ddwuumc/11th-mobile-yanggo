import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/favorite_check_dto.dart';
import '../models/favorite_response_dto.dart';

// MovieLog 즐겨찾기 API(/v8/favorites). 보호용 Dio(JWT Interceptor 포함)를 받아 씁니다.
class FavoriteApiService {
  FavoriteApiService(this._dio);

  final Dio _dio;

  // 등록: 201, result에 FavoriteResponseDto
  Future<FavoriteResponseDto> addFavorite({required int movieId}) async {
    final response = await _dio.post(
      '/v8/favorites',
      data: {'movieId': movieId},
    );
    final body = CommonResponse<FavoriteResponseDto>.fromJson(
      response.data as Map<String, dynamic>,
      FavoriteResponseDto.fromJson,
    );
    final result = body.result;
    if (result == null) throw StateError('즐겨찾기 등록 result가 없습니다.');
    return result;
  }

  // 내 목록: 200, result가 배열(없으면 빈 배열)
  Future<List<FavoriteResponseDto>> fetchMyFavorites() async {
    final response = await _dio.get('/v8/favorites');
    final body = CommonResponse<List<FavoriteResponseDto>>.fromJson(
      response.data as Map<String, dynamic>,
      (value) =>
          (value as List<dynamic>).map(FavoriteResponseDto.fromJson).toList(),
    );
    return body.result ?? const [];
  }

  // 특정 영화의 즐겨찾기 여부
  Future<FavoriteCheckDto> checkFavorite({required int movieId}) async {
    final response = await _dio.get('/v8/favorites/$movieId');
    final body = CommonResponse<FavoriteCheckDto>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => FavoriteCheckDto.fromJson(value, movieId: movieId),
    );
    final result = body.result;
    if (result == null) throw StateError('즐겨찾기 여부 result가 없습니다.');
    return result;
  }

  // 해제: 200, result는 null (평점 삭제 API와 같은 200이지만 경로는 favoriteId가 아니라 movieId)
  Future<void> deleteFavorite({required int movieId}) async {
    await _dio.delete('/v8/favorites/$movieId');
  }
}
