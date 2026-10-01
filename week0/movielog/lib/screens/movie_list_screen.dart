import 'package:flutter/material.dart';

import '../models/mock_movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const _genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러'];
  String _selectedGenre = '전체';

  List<MockMovie> get _filteredMovies {
    if (_selectedGenre == '전체') return mockMovies;
    return mockMovies.where((movie) => movie.genre == _selectedGenre).toList();
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
                    onSelected: (_) => setState(() => _selectedGenre = genre),
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
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredMovies.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.5,
                ),
                itemBuilder: (context, index) {
                  final movie = _filteredMovies[index];
                  return MovieCard(
                    movie: movie,
                    width: double.infinity,
                    showRatingBadge: true,
                    subtitle: '${movie.year} · ${movie.genre}',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
