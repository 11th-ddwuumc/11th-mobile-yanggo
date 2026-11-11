import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/movie_detail_view_model.dart';
import '../view_models/sign_up_view_model.dart' show SubmitStatus;
import '../widgets/common_app_bar.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId, this.movie});

  final int? movieId;
  final TmdbMovieDto? movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;

  Future<void> _openRatingDialog() async {
    final viewModel = context.read<MovieDetailViewModel>();

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          await viewModel.createRating(score: score, comment: comment);
          if (viewModel.submitStatus != SubmitStatus.success) {
            throw StateError(viewModel.submitMessage ?? '저장에 실패했습니다.');
          }
        },
      ),
    );

    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    if (movie == null || movie.id != widget.movieId) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
        body: const Center(child: Text('영화 정보를 불러올 수 없어요')),
      );
    }

    final viewModel = context.read<MovieDetailViewModel>();

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: CommonAppBar(
        title: '',
        onBack: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: TmdbPosterImage(posterPath: movie.posterPath),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: AppTextStyles.titleLarge),
                    const SizedBox(height: 4),
                    if (movie.releaseYear != null)
                      Text(movie.releaseYear!, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: movie.voteAverage / 2,
                          itemCount: 5,
                          itemSize: 20,
                          itemBuilder: (context, index) =>
                              const Icon(Icons.star, color: AppColors.violet),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.violet,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      '시놉시스',
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    if (movie.overview.isEmpty)
                      const Center(
                        child: Text(
                          '줄거리 정보가 없어요.',
                          style: AppTextStyles.bodySmall,
                        ),
                      )
                    else
                      Text(movie.overview, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 29),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _toggleFavorite,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.violet,
                              side: const BorderSide(color: AppColors.violet),
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            icon: Icon(
                              _isFavorite
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                            ),
                            label: const Text('즐겨찾기'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: viewModel.memberId == null
                                ? null
                                : _openRatingDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.violet,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            icon: SvgPicture.asset(
                              'assets/icons/rate_button_icon.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: const Text('평점 남기기'),
                          ),
                        ),
                      ],
                    ),
                    if (viewModel.memberId == null) ...[
                      const SizedBox(height: 12),
                      const Text(
                        '평점을 남기려면 학습용 회원가입이 필요합니다.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
