import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../models/mock_movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int? movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  double? _myRating;

  Future<void> _openRatingDialog() async {
    final rating = await showDialog<double>(
      context: context,
      builder: (context) => const RatingDialog(),
    );
    if (rating == null) return;
    setState(() => _myRating = rating);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('평점 ${rating.toStringAsFixed(1)}점을 저장했습니다.'),
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
    final movie = findMovieById(widget.movieId);

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
        body: const Center(child: Text('영화를 찾을 수 없습니다')),
      );
    }

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
                child: Image.asset(
                  movie.posterAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: AppTextStyles.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.year} · ${movie.genre}',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: 4.5,
                          itemCount: 5,
                          itemSize: 20,
                          itemBuilder: (context, index) =>
                              const Icon(Icons.star, color: AppColors.violet),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '4.5',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.violet,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('(1,245)', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in movie.displayTags)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.chipNeutral,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(tag, style: AppTextStyles.bodySmall),
                          ),
                      ],
                    ),
                    if (_myRating != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '내가 남긴 평점: ${_myRating!.toStringAsFixed(1)}점',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.violet,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      '시놉시스',
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${movie.title}은(는) ${movie.genre} 장르의 작품으로, '
                      'MovieLog에서 Mock 데이터로 제공하는 소개 문구입니다.',
                      style: AppTextStyles.bodyMedium,
                    ),
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
                            onPressed: _openRatingDialog,
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
