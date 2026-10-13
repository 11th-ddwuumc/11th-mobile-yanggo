import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleMedium.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
