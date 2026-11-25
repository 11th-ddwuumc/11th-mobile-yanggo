import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../view_models/load_phase.dart';
import '../view_models/paged_movies_view_model.dart';
import 'movielog_button.dart';

class MoviePageFooter extends StatelessWidget {
  const MoviePageFooter({
    super.key,
    required this.viewModel,
    this.moreLabel = '더 보기',
  });

  final PagedMoviesViewModel viewModel;
  final String moreLabel;

  @override
  Widget build(BuildContext context) {
    // 마지막 page: 더 보기를 숨기고 끝 상태를 보여줌
    if (!viewModel.hasMore &&
        !viewModel.isLoadingMore &&
        viewModel.loadMoreError == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Text(
          '모든 영화를 확인했습니다.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      );
    }

    final hasError = viewModel.loadMoreError != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          if (hasError) ...[
            Text(
              viewModel.loadMoreError!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
          ],
          MovieLogButton(
            label: hasError ? '다음 페이지 다시 시도' : moreLabel,
            width: double.infinity,
            height: 48,
            isLoading: viewModel.isLoadingMore,
            onPressed: viewModel.phase == LoadPhase.ready
                ? viewModel.loadNextPage
                : null,
          ),
        ],
      ),
    );
  }
}
