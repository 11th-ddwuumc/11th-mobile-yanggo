class Movie {
  final String title;
  final double rating;
  final String? nickname;

  Movie({required this.title, required this.rating, this.nickname});

  String get displayNickname => nickname ?? '익명';
}
