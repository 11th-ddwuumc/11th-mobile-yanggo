import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_dto.dart';
import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';
import '../widgets/movielog_button.dart';
import '../widgets/rating_dialog.dart';
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
                title: viewModel.refreshWarning != null
                    ? '저장은 완료됐어요'
                    : '평점을 불러오지 못했어요',
                message:
                    viewModel.refreshWarning ??
                    viewModel.message ??
                    '잠시 후 다시 시도해 주세요.',
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

Future<void> _onEditPressed(BuildContext context, RatingDto rating) async {
  final viewModel = context.read<MyRatingsViewModel>();
  final messenger = ScaffoldMessenger.of(context);

  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => RatingDialog(
      initialScore: rating.score,
      initialComment: rating.comment,
      onSubmit: (score, comment) => viewModel.updateRating(
        ratingId: rating.ratingId,
        score: score,
        comment: comment,
      ),
    ),
  );

  if (saved != true) return;
  messenger.showSnackBar(
    const SnackBar(
      content: Text('평점을 수정했습니다.'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<void> _onDeletePressed(BuildContext context, RatingDto rating) async {
  final viewModel = context.read<MyRatingsViewModel>();
  final messenger = ScaffoldMessenger.of(context);

  final deleted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DeleteRatingDialog(
      onConfirm: () => viewModel.deleteRating(rating.ratingId),
    ),
  );

  if (deleted != true) return;
  messenger.showSnackBar(
    const SnackBar(
      content: Text('평점을 삭제했습니다.'),
      behavior: SnackBarBehavior.floating,
    ),
  );
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
          _RatingCard(
            entry: entry,
            onEdit: () => _onEditPressed(context, entry.rating),
            onDelete: () => _onDeletePressed(context, entry.rating),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final RatingWithMovie entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
          const SizedBox(width: 16),
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
          const SizedBox(width: 12),
          Column(
            children: [
              _CardActionButton(
                label: '수정',
                background: AppColors.statBorder.withValues(alpha: 0.6),
                foreground: AppColors.deepViolet,
                onPressed: onEdit,
              ),
              const SizedBox(height: 8),
              _CardActionButton(
                label: '삭제',
                background: AppColors.errorBackground.withValues(alpha: 0.5),
                foreground: AppColors.error,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        fixedSize: const Size(63, 35),
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;
  String? _errorText;

  Future<void> _onConfirm() async {
    setState(() {
      _isDeleting = true;
      _errorText = null;
    });
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorText = error is StateError
            ? error.message
            : '삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '평점을 삭제할까요?',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 12),
              const Text(
                '삭제한 평점은 복구할 수 없습니다.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextButton(
                        onPressed: _isDeleting
                            ? null
                            : () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.statBorder.withValues(
                            alpha: 0.6,
                          ),
                          foregroundColor: AppColors.deepViolet,
                          disabledBackgroundColor: AppColors.statBorder
                              .withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('취소'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MovieLogButton(
                      label: '삭제',
                      isLoading: _isDeleting,
                      onPressed: _isDeleting ? null : _onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
