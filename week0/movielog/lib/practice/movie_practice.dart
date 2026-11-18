import '../models/movie.dart';

void main() {
  final movies = [
    Movie(title: '인터스텔라', rating: 4.5, nickname: '영화광민수'),
    Movie(title: '기생충', rating: 5.0),
    Movie(title: '라라랜드', rating: 4.2, nickname: '뮤지컬러버'),
  ];

  for (final movie in movies) {
    print('${movie.title} - ⭐${movie.rating} (닉네임: ${movie.displayNickname})');
  }

  // map으로 출력
  final titles = movies.map((movie) => movie.title);
  print('영화 제목 목록: ${titles.join(', ')}');
}
