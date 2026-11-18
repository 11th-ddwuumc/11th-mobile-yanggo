import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/form_field_label.dart';
import '../widgets/movielog_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  late final AuthViewModel _auth;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthViewModel>();
    _auth.addListener(_showSessionExpired);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSessionExpired());
  }

  void _showSessionExpired() {
    if (!mounted || !_auth.sessionExpired) return;
    _auth.consumeSessionExpired();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('로그인이 만료됐어요. 다시 로그인해 주세요.')));
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    _auth.login(_emailController.text, _passwordController.text);
  }

  InputDecoration _decoration(String hint, {String? errorText}) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.hint, fontSize: 16),
      filled: true,
      fillColor: AppColors.white,
      errorText: errorText,
      errorMaxLines: 2,
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      enabledBorder: border(AppColors.inputBorder),
      disabledBorder: border(AppColors.inputBorder),
      focusedBorder: border(AppColors.violet, width: 2),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, width: 2),
    );
  }

  @override
  void dispose() {
    _auth.removeListener(_showSessionExpired);
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final loading = auth.status == AuthStatus.authenticating;
    final enabled = !loading && !auth.storageCleanupInProgress;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: const CommonAppBar(title: '로그인', centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Center(
                  child: SvgPicture.asset(
                    'assets/logos/movielog_logo.svg',
                    width: 72,
                    height: 72,
                    semanticsLabel: 'MovieLog 로고',
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'MovieLog에 로그인',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 40),
                const FormFieldLabel(label: '이메일'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _emailController,
                  enabled: enabled,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration('이메일 주소를 입력해주세요'),
                  validator: (value) =>
                      (value?.trim().isEmpty ?? true) ? '이메일을 입력해 주세요.' : null,
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),
                const SizedBox(height: 16),
                const FormFieldLabel(label: '비밀번호'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  enabled: enabled,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: _decoration(
                    '비밀번호를 입력해주세요',
                    errorText: auth.message,
                  ),
                  validator: (value) =>
                      (value?.isEmpty ?? true) ? '비밀번호를 입력해 주세요.' : null,
                  onFieldSubmitted: (_) {
                    if (enabled) _submit();
                  },
                ),
                const SizedBox(height: 96),
                MovieLogButton(
                  label: '로그인',
                  width: double.infinity,
                  height: 56,
                  isLoading: loading,
                  onPressed: enabled ? _submit : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '계정이 없나요?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    TextButton(
                      onPressed: enabled ? () => context.go('/register') : null,
                      child: const Text('회원가입'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
