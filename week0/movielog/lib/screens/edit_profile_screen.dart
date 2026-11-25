import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/form_field_label.dart';
import '../widgets/movielog_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final member = context.read<AuthViewModel>().member;
    _controller = TextEditingController(text: member?.nickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final viewModel = context.read<EditProfileViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    FocusScope.of(context).unfocus();
    final success = await viewModel.save(_controller.text);
    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text('프로필을 수정했어요.')));
      router.pop();
    } else if (viewModel.message != null) {
      messenger.showSnackBar(SnackBar(content: Text(viewModel.message!)));
    }
  }

  InputDecoration _decoration({String? errorText, bool readOnly = false}) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      filled: true,
      fillColor: readOnly
          ? AppColors.statBorder.withValues(alpha: 0.5)
          : AppColors.white,
      errorText: errorText,
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      enabledBorder: border(AppColors.inputBorder),
      disabledBorder: border(
        readOnly ? AppColors.statBorder : AppColors.inputBorder,
      ),
      focusedBorder: border(AppColors.violet, width: 2),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, width: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthViewModel, String?>(
      (auth) => auth.member?.email,
    );

    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, child) {
        final saving = viewModel.status == EditProfileStatus.saving;

        return PopScope(
          canPop: !saving,
          child: Scaffold(
            backgroundColor: AppColors.warmWhite,
            appBar: CommonAppBar(
              title: '프로필 수정',
              centerTitle: true,
              onBack: saving ? () {} : () => context.pop(),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const FormFieldLabel(label: '이메일 (변경할 수 없습니다)'),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: email,
                      enabled: false,
                      style: const TextStyle(color: AppColors.hint),
                      decoration: _decoration(readOnly: true),
                    ),
                    const SizedBox(height: 16),
                    const FormFieldLabel(label: '닉네임'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _controller,
                      enabled: !saving,
                      maxLength: 12,
                      onChanged: (_) => viewModel.onNicknameChanged(),
                      buildCounter: (
                        context, {
                        required currentLength,
                        required isFocused,
                        required maxLength,
                      }) => Text('$currentLength / $maxLength'),
                      decoration: _decoration(
                        errorText: viewModel.nicknameError,
                      ),
                    ),
                    const Spacer(),
                    MovieLogButton(
                      label: '저장',
                      width: double.infinity,
                      height: 56,
                      isLoading: saving,
                      onPressed: saving ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
