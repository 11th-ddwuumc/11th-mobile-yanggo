import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/load_phase.dart';
import '../view_models/paged_movies_view_model.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';
import '../widgets/movie_page_footer.dart';

import 'package:go_router/go_router.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

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
                  IconButton(
                    onPressed: () => context.push('/movies/search'),
                    icon: const Icon(Icons.search, color: AppColors.violet),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Consumer<PagedMoviesViewModel>(
              builder: (context, viewModel, _) {
                final genres = viewModel.genres;

                return SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: genres.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final genreId = index == 0 ? null : genres[index - 1].id;
                      final label = index == 0 ? '전체' : genres[index - 1].name;
                      final isSelected = genreId == viewModel.selectedGenreId;

                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) {
                          if (genreId == viewModel.selectedGenreId) return;
                          context.read<PagedMoviesViewModel>().loadInitial(
                            genreId: genreId,
                          );
                        },
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
                );
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<PagedMoviesViewModel>(
                builder: (context, viewModel, _) {
                  return switch (viewModel.phase) {
                    LoadPhase.idle ||
                    LoadPhase.loading => const MovieListLoading(),
                    LoadPhase.error => MovieListError(
                      onRetry: () => viewModel.loadInitial(
                        genreId: viewModel.selectedGenreId,
                      ),
                    ),
                    LoadPhase.empty => const MovieListEmpty(),
                    LoadPhase.ready => MovieGrid(
                      movies: viewModel.movies,
                      genreNames: {
                        for (final genre in viewModel.genres)
                          genre.id: genre.name,
                      },
                      footer: MoviePageFooter(viewModel: viewModel),
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
