import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';
import '../widgets/tmdb_poster_image.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: CommonAppBar(
        title: '내가 등록한 평점',
        centerTitle: true,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: Consumer<MyRatingsViewModel>(
          builder: (context, viewModel, _) {
            return switch (viewModel.status) {
              MyRatingsLoadStatus.idle ||
              MyRatingsLoadStatus.loading => const MovieListLoading(),
              MyRatingsLoadStatus.error => MovieListError(
                title: '평점을 불러오지 못했어요',
                message: viewModel.message ?? '잠시 후 다시 시도해 주세요.',
                onRetry: () => context.read<MyRatingsViewModel>().load(),
              ),
              MyRatingsLoadStatus.empty => const MovieListEmpty(
                message: '아직 등록한 평점이 없어요.',
              ),
              MyRatingsLoadStatus.success => _RatingList(
                ratings: viewModel.ratings,
                notice: viewModel.message,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _RatingList extends StatelessWidget {
  const _RatingList({required this.ratings, this.notice});

  final List<RatingWithMovie> ratings;
  final String? notice;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (notice != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(notice!, style: AppTextStyles.bodySmall),
          ),
        for (final entry in ratings) ...[
          _RatingCard(entry: entry),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.entry});

  final RatingWithMovie entry;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final movie = entry.movie;
    final comment = rating.comment;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 82,
              height: 124,
              child: TmdbPosterImage(posterPath: movie?.posterPath),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie?.title ?? '영화 #${rating.movieId}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 10),
                Text(
                  '별점 ${rating.score} / 5',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.violet,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (comment != null && comment.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
                if (movie == null) ...[
                  const SizedBox(height: 8),
                  const Text('포스터 정보 없음', style: AppTextStyles.bodySmall),
                ],
                const SizedBox(height: 8),
                Text(
                  _formatDate(rating.createdAt),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
