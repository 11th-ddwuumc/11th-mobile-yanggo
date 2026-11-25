class MockMovie {
  const MockMovie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.rating,
    this.tags,
  });

  final int id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
  final double rating;
  final List<String>? tags;

  List<String> get displayTags => tags ?? [genre];
}

const mockMovies = [
  MockMovie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2023,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rating: 4.8,
    tags: ['로맨스', '드라마', '감동적인'],
  ),
  MockMovie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.2,
  ),
  MockMovie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.9,
  ),
  MockMovie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 3.8,
  ),
  MockMovie(
    id: 5,
    title: '네 번째 오후',
    genre: '로맨스',
    year: 2021,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.5,
  ),
  MockMovie(
    id: 6,
    title: '도시의 선',
    genre: '다큐멘터리',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    rating: 4.1,
  ),
];

MockMovie? findMovieById(int? id) {
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}
