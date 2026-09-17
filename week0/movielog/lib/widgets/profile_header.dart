import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
        Text('무비러버', style: AppTextStyles.titleLarge.copyWith(fontSize: 22)),
        const SizedBox(height: 8),
        Text(
          '매주 주말엔 영화관으로 출근하는 프로 관람객.\n좋은 영화를 보고 기록하는 것을 좋아합니다.',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
