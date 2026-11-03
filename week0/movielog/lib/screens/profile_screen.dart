import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: const CommonAppBar(title: '내 프로필'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileHeader(),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.violet,
                    side: const BorderSide(color: AppColors.violet),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fixedSize: const Size(127, 42),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('프로필 수정'),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: StatItem(label: '본 영화', value: '342'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatItem(
                        label: '평점',
                        value: '4.2',
                        icon: SvgPicture.asset(
                          'assets/icons/star.svg',
                          width: 16,
                          height: 16,
                          semanticsLabel: '평점 별 아이콘',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: StatItem(label: '즐겨찾기', value: '58'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/my/ratings'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '내가 등록한 평점',
                        style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.violet,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                '선호하는 장르',
                style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: const Text('드라마'),
                    backgroundColor: AppColors.statBorder,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  Chip(
                    label: const Text('SF'),
                    backgroundColor: AppColors.statBorder,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  Chip(
                    label: const Text('애니메이션'),
                    backgroundColor: AppColors.statBorder,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
