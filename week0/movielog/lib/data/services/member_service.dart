import 'package:dio/dio.dart';

import '../models/availability_dto.dart';
import '../models/common_response.dart';
import '../models/create_member_request.dart';
import '../models/rating_dto.dart';
import '../models/sign_up_models.dart';
import '../models/rating_request.dart';

class MemberService {
  MemberService(this._dio);

  final Dio _dio;

  Future<AvailabilityDto> checkNickname(String nickname) async {
    final response = await _dio.get(
      '/v6/members/nickname/${Uri.encodeComponent(nickname)}',
    );
    return AvailabilityDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AvailabilityDto> checkEmail(String email) async {
    final response = await _dio.get(
      '/v6/members/email/${Uri.encodeComponent(email)}',
    );
    return AvailabilityDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CommonResponse<SignUpResult>> signUp(
    CreateMemberRequest request,
  ) async {
    final response = await _dio.post('/v6/members', data: request.toJson());
    return CommonResponse<SignUpResult>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => SignUpResult.fromJson(value as Map<String, dynamic>),
    );
  }

  Future<List<RatingDto>> fetchRatings(int memberId) async {
    final response = await _dio.get('/v5/members/$memberId/ratings');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createRating({
    required int memberId,
    required CreateRatingRequest request,
  }) async {
    final response = await _dio.post(
      '/v6/members/$memberId/ratings',
      data: request.toJson(),
    );
    if (response.statusCode != 201) {
      throw StateError('예상하지 못한 등록 응답: ${response.statusCode}');
    }
  }

  Future<void> updateRating({
    required int memberId,
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    await _dio.patch(
      '/v6/members/$memberId/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
  }

  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    final response = await _dio.delete(
      '/v6/members/$memberId/ratings/$ratingId',
    );
    if (response.statusCode != 204) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}

String writeSignUpErrorMessage(DioException error) {
  final data = error.response?.data;
  final common = data is Map<String, dynamic>
      ? CommonResponse<Object?>.fromJson(data, (value) => value)
      : null;
  return common?.message ?? '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

String writeErrorMessage(DioException error) {
  final data = error.response?.data;
  final common = data is Map<String, dynamic>
      ? CommonResponse<Object?>.fromJson(data, (value) => value)
      : null;
  return common?.message ?? '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

bool shouldRefreshAfterRatingError(DioException error) {
  final data = error.response?.data;
  final code = data is Map<String, dynamic> ? data['code'] as String? : null;
  return code == 'COMMON403' || code == 'COMMON404';
}
