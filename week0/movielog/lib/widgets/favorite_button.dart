import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/favorite_detail_view_model.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key});

  Future<void> _toggle(
    BuildContext context,
    FavoriteDetailViewModel viewModel,
  ) async {
    await viewModel.toggle();
    if (!context.mounted || viewModel.errorMessage != null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteDetailViewModel>(
      builder: (context, viewModel, _) {
        final busy = viewModel.isLoading || viewModel.isSaving;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: busy
                  ? const Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.violet,
                        ),
                      ),
                    )
                  : IconButton(
                      color: AppColors.violet,
                      onPressed: viewModel.hasLoadedStatus
                          ? () => _toggle(context, viewModel)
                          : null,
                      icon: Icon(
                        viewModel.isFavorite
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            const Text(
              '즐겨찾기',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.violet,
              ),
            ),
            // 첫 여부 조회에 실패했을 때만 다시 확인 버튼을 보여 줍니다.
            if (!viewModel.hasLoadedStatus && !viewModel.isLoading)
              IconButton(
                tooltip: '여부 다시 확인',
                color: AppColors.violet,
                onPressed: viewModel.load,
                icon: const Icon(Icons.refresh),
              ),
          ],
        );
      },
    );
  }
}
