import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/widgets/term_checkbox.dart';

import '../theme/app_colors.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/form_field_label.dart';
import '../widgets/submit_button.dart';

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

  bool get _canSubmit =>
      _validateNickname(_nicknameController.text) == null &&
      _validateEmail(_emailController.text) == null &&
      _validatePassword(_passwordController.text) == null &&
      _agreedToTerms;

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    FocusScope.of(context).unfocus();
  }

  InputDecoration _decoration(
    String hint,
    TextEditingController controller,
    String? Function(String?) validator,
  ) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final text = controller.text;
    final hasText = text.isNotEmpty;
    final error = hasText ? validator(text) : null;
    final isValid = hasText && error == null;
    final isInvalid = error != null;

    Widget? suffixIcon;
    if (isValid || isInvalid) {
      suffixIcon = Padding(
        padding: const EdgeInsets.all(12),
        child: SvgPicture.asset(
          isValid ? 'assets/icons/check_circle.svg' : 'assets/icons/error.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            isValid ? AppColors.violet : AppColors.error,
            BlendMode.srcIn,
          ),
        ),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.hint, fontSize: 16),
      filled: true,
      fillColor: isInvalid
          ? AppColors.errorBackground
          : AppColors.statBackground,
      suffixIcon: suffixIcon,
      enabledBorder: border(AppColors.inputBorder),
      focusedBorder: border(AppColors.violet, width: 2),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, width: 2),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                TextFormField(
                  controller: _nicknameController,
                  decoration: _decoration(
                    '닉네임을 입력해주세요',
                    _nicknameController,
                    _validateNickname,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _validateNickname,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                ),
                const SizedBox(height: 16),
                const FormFieldLabel(label: '이메일'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  decoration: _decoration(
                    '이메일 주소를 입력해주세요',
                    _emailController,
                    _validateEmail,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
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
                SubmitButton(
                  label: '가입하기',
                  onPressed: _canSubmit ? _submit : null,
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
