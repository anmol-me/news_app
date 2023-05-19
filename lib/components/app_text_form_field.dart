import 'package:flutter/material.dart';
import 'package:news_app/common/constants.dart';

class AppTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextStyle? labelStyle;
  final String? errorMessage;
  final String? Function(String?)? validator;
  final ValueNotifier<bool>? focus;

  const AppTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.labelStyle,
    this.errorMessage = 'Field cannot be empty',
    this.validator,
    this.focus,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: labelStyle ??
            TextStyle(
              color: focus!.value ? colorRed : colorAppbarForeground,
            ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1.5,
            color: colorRed,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
      validator: validator ??
          (val) {
            if (controller.text.isEmpty) {
              return errorMessage;
            } else {
              return null;
            }
          },
    );
  }
}