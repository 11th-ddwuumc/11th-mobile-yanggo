import 'package:flutter/material.dart';

import '../models/mock_movie.dart';
import '../services/fake_movie_service.dart';
import '../services/genre_preference.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const _genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러'];
  static const _initialMode = MovieLoadMode.success;

  final _movieService = const FakeMovieService();
  final _genrePreference = GenrePreference();
  late Future<List<MockMovie>> _moviesFuture;
  String _selectedGenre = '전체';

  @override
  void initState() {
    super.initState();
    _moviesFuture = _movieService.fetchMovies(mode: _initialMode);
    _restoreGenre();
  }

  Future<void> _restoreGenre() async {
    final saved = await _genrePreference.read();
    if (!mounted) return;
    if (!_genres.contains(saved)) return;
    setState(() => _selectedGenre = saved);
  }

  Future<void> _selectGenre(String genre) async {
    setState(() => _selectedGenre = genre);
    await _genrePreference.save(genre);
  }

  void _retry() {
    setState(() {
      _moviesFuture = _movieService.fetchMovies();
    });
  }

  List<MockMovie> _filterByGenre(List<MockMovie> movies) {
    if (_selectedGenre == '전체') return movies;
    return movies.where((movie) => movie.genre == _selectedGenre).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '영화',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.violet,
                    ),
                  ),
                  const Icon(Icons.search, color: AppColors.violet),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _genres.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  final isSelected = genre == _selectedGenre;
                  return ChoiceChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (_) => _selectGenre(genre),
                    selectedColor: AppColors.violet,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.statBackground,
                    shape: const StadiumBorder(),
                    side: BorderSide.none,
                    showCheckmark: false,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<MockMovie>>(
                future: _moviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const MovieListLoading();
                  }

                  if (snapshot.hasError) {
                    return MovieListError(onRetry: _retry);
                  }

                  final movies = _filterByGenre(
                    snapshot.data ?? const <MockMovie>[],
                  );

                  if (movies.isEmpty) {
                    return const MovieListEmpty();
                  }

                  return MovieGrid(movies: movies);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
