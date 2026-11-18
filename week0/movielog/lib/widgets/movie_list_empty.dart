import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MovieListEmpty extends StatelessWidget {
  const MovieListEmpty({super.key, this.message = '조건에 맞는 영화가 없습니다.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.movie_outlined, size: 48, color: AppColors.violet),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
