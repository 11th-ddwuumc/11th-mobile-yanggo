import 'package:flutter/material.dart';

import '../data/models/member_info.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/auth_view_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.member,
    required this.status,
    required this.onRetry,
  });

  final MemberInfo? member;
  final MemberLoadStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final info = member;

    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/profile/profile_movielog.jpg',
            width: 128,
            height: 128,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        if (info != null) ...[
          Text(
            info.nickname,
            style: AppTextStyles.titleLarge.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            info.email,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ] else if (status == MemberLoadStatus.error) ...[
          const Text('내 정보를 불러오지 못했어요.', style: AppTextStyles.bodySmall),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ] else
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}
