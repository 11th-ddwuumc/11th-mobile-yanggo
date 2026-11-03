import 'package:dio/dio.dart';

import '../models/availability_dto.dart';
import '../models/rating_dto.dart';

class MemberService {
  MemberService(this._dio);

  final Dio _dio;

  Future<AvailabilityDto> checkNickname(String nickname) async {
    final response = await _dio.get(
      '/members/nickname/${Uri.encodeComponent(nickname)}',
    );
    return AvailabilityDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AvailabilityDto> checkEmail(String email) async {
    final response = await _dio.get(
      '/members/email/${Uri.encodeComponent(email)}',
    );
    return AvailabilityDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<RatingDto>> fetchRatings(int memberId) async {
    final response = await _dio.get('/members/$memberId/ratings');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
