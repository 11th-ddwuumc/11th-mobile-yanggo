import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/favorite_list_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/load_phase.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';
import '../widgets/tmdb_poster_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoritesViewModel>().refresh();
    });
  }

  Future<void> _openDetail(FavoriteListItem item) async {
    final movie = item.movie;
    if (movie == null) return;
    final viewModel = context.read<FavoritesViewModel>();

    await context.push('/movies/${movie.id}', extra: movie);
    if (!mounted) return;
    // 상세에서 해제했을 수 있으니 돌아오면 목록을 다시 조회합니다.
    await viewModel.refresh(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: CommonAppBar(
        title: '내 즐겨찾기',
        centerTitle: true,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: Consumer<FavoritesViewModel>(
          builder: (context, viewModel, _) {
            switch (viewModel.phase) {
              case LoadPhase.idle:
              case LoadPhase.loading:
                return const MovieListLoading();
              case LoadPhase.empty:
                return const MovieListEmpty(
                  icon: Icons.bookmark_border,
                  message: '아직 즐겨찾기한 영화가 없습니다.',
                  subMessage: '영화 상세에서 북마크를 눌러보세요.',
                );
              case LoadPhase.error:
                return MovieListError(
                  title: viewModel.errorMessage ?? '즐겨찾기를 불러오지 못했습니다.',
                  message: '잠시 후 다시 시도해 주세요.',
                  onRetry: () => viewModel.refresh(),
                );
              case LoadPhase.ready:
                return RefreshIndicator(
                  onRefresh: () => viewModel.refresh(silent: true),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = viewModel.items[index];
                      return _FavoriteCard(
                        item: item,
                        onTap: item.hasMovie ? () => _openDetail(item) : null,
                        onRetry: () =>
                            viewModel.retryItem(item.favorite.movieId),
                      );
                    },
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.item, this.onTap, required this.onRetry});

  final FavoriteListItem item;
  final VoidCallback? onTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final movie = item.movie;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 92,
                // 영화 정보가 없으면 TmdbPosterImage가 placeholder를 보여 줍니다.
                child: TmdbPosterImage(posterPath: movie?.posterPath),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie?.title ?? '영화 #${item.favorite.movieId}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'TMDB 영화 ID로 연결합니다.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '즐겨찾기한 영화',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.violet,
                    ),
                  ),
                  if (!item.hasMovie)
                    TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      child: const Text(
                        '정보 다시 불러오기',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
