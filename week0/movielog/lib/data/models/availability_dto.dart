class AvailabilityDto {
  const AvailabilityDto({required this.available});

  final bool available;

  factory AvailabilityDto.fromJson(Map<String, dynamic> json) {
    return AvailabilityDto(available: json['available'] as bool);
  }
}
