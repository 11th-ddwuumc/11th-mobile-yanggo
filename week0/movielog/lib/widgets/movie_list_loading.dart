import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MovieListLoading extends StatelessWidget {
  const MovieListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.violet),
    );
  }
}
