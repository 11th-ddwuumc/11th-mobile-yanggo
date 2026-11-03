import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/form_field_label.dart';
import '../widgets/movielog_button.dart';
import '../widgets/term_checkbox.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _agreedToTerms = false;

  String? _validateNickname(String? value) {
    final nickname = value?.trim() ?? '';
    if (nickname.isEmpty) return '닉네임을 입력해주세요.';
    if (nickname.length < 2) return '닉네임은 2자 이상이어야 합니다.';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return '이메일을 입력해주세요.';
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) return '올바른 이메일 형식이 아닙니다.';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return '비밀번호를 입력해주세요.';
    if (password.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
    return null;
  }

  bool _canSubmit(SignUpViewModel viewModel) =>
      _validateNickname(_nicknameController.text) == null &&
      _validateEmail(_emailController.text) == null &&
      _validatePassword(_passwordController.text) == null &&
      _agreedToTerms &&
      !viewModel.isSubmitBlocked;

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    FocusScope.of(context).unfocus();
    context.go('/home');
  }

  InputDecoration _decoration(
    String hint,
    TextEditingController controller,
    String? Function(String?) validator, {
    CheckStatus? status,
    String? serverError,
  }) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final text = controller.text;
    final localError = text.isEmpty ? null : validator(text);
    final hasError = localError != null || serverError != null;
    final isAvailable = status == CheckStatus.available && localError == null;

    Widget? suffixIcon;
    if (hasError || isAvailable) {
      suffixIcon = Padding(
        padding: const EdgeInsets.all(12),
        child: SvgPicture.asset(
          isAvailable
              ? 'assets/icons/check_circle.svg'
              : 'assets/icons/error.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            isAvailable ? AppColors.violet : AppColors.error,
            BlendMode.srcIn,
          ),
        ),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.hint, fontSize: 16),
      filled: true,
      fillColor: hasError
          ? AppColors.errorBackground
          : AppColors.statBackground,
      suffixIcon: suffixIcon,
      enabledBorder: border(hasError ? AppColors.error : AppColors.inputBorder),
      focusedBorder: border(
        hasError ? AppColors.error : AppColors.violet,
        width: 2,
      ),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, width: 2),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _fieldFeedback({
    required String text,
    required String? Function(String?) validator,
    required CheckStatus status,
    required String? serverError,
    required String available,
    required String checking,
  }) {
    final localError = text.isEmpty ? null : validator(text);

    if (localError != null) return _message(localError, AppColors.error);
    if (serverError != null) return _message(serverError, AppColors.error);
    if (status == CheckStatus.available) {
      return _message(available, AppColors.success);
    }
    if (status == CheckStatus.checking) {
      return _message(checking, AppColors.info);
    }
    return const SizedBox.shrink();
  }

  Widget _message(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: CommonAppBar(title: '회원가입', centerTitle: true, onBack: () {}),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 48),
                const FormFieldLabel(label: '닉네임'),
                const SizedBox(height: 4),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nicknameController,
                          decoration: _decoration(
                            '닉네임을 입력해주세요',
                            _nicknameController,
                            _validateNickname,
                            status: viewModel.nicknameCheckStatus,
                            serverError: viewModel.nicknameErrorText,
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: viewModel.onNicknameChanged,
                          onFieldSubmitted: (_) =>
                              _emailFocusNode.requestFocus(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      MovieLogButton(
                        label: '중복 확인',
                        width: 102,
                        height: null,
                        isLoading:
                            viewModel.nicknameCheckStatus ==
                            CheckStatus.checking,
                        onPressed:
                            viewModel.canCheckNickname &&
                                _validateNickname(_nicknameController.text) ==
                                    null
                            ? () => viewModel.checkNickname(
                                _nicknameController.text,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                _fieldFeedback(
                  text: _nicknameController.text,
                  validator: _validateNickname,
                  status: viewModel.nicknameCheckStatus,
                  serverError: viewModel.nicknameErrorText,
                  available: '사용 가능한 닉네임입니다.',
                  checking: '닉네임 사용 가능 여부를 확인 중입니다.',
                ),
                const SizedBox(height: 16),
                const FormFieldLabel(label: '이메일'),
                const SizedBox(height: 4),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          decoration: _decoration(
                            '이메일 주소를 입력해주세요',
                            _emailController,
                            _validateEmail,
                            status: viewModel.emailCheckStatus,
                            serverError: viewModel.emailErrorText,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: viewModel.onEmailChanged,
                          onFieldSubmitted: (_) =>
                              _passwordFocusNode.requestFocus(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      MovieLogButton(
                        label: '중복 확인',
                        width: 102,
                        height: null,
                        isLoading:
                            viewModel.emailCheckStatus == CheckStatus.checking,
                        onPressed:
                            viewModel.canCheckEmail &&
                                _validateEmail(_emailController.text) == null
                            ? () => viewModel.checkEmail(_emailController.text)
                            : null,
                      ),
                    ],
                  ),
                ),
                _fieldFeedback(
                  text: _emailController.text,
                  validator: _validateEmail,
                  status: viewModel.emailCheckStatus,
                  serverError: viewModel.emailErrorText,
                  available: '사용 가능한 이메일입니다.',
                  checking: '이메일 사용 가능 여부를 확인 중입니다.',
                ),
                const SizedBox(height: 16),
                const FormFieldLabel(label: '비밀번호'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: _decoration(
                    '비밀번호를 입력해주세요',
                    _passwordController,
                    _validatePassword,
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: _validatePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
                const SizedBox(height: 210),
                TermsCheckbox(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 16),
                MovieLogButton(
                  label: '가입하기',
                  width: double.infinity,
                  height: 56,
                  onPressed: _canSubmit(viewModel) ? _submit : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '이미 계정이 있나요?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('로그인')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
