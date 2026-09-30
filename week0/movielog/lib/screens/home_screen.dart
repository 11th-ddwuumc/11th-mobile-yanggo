import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/widgets/movie_card.dart';

import '../models/mock_movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = mockMovies.first;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MovieLog',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.violet,
                    ),
                  ),
                  const Icon(Icons.search, color: AppColors.violet),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '오늘은 어떤\n영화를 볼까요?',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/movies/${featured.id}'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Image.asset(
                          featured.posterAsset,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.75),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.deepViolet,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                '추천 신작',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              featured.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${featured.genre} · ${featured.year}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    context.push('/movies/${featured.id}'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.deepViolet,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                icon: const Icon(Icons.info_outline, size: 18),
                                label: const Text('상세보기'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '인기 영화',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 22,
                      color: AppColors.deepViolet,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '전체보기',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.deepViolet,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppColors.deepViolet,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 276,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: mockMovies.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      MovieCard(movie: mockMovies[index], rank: index + 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
