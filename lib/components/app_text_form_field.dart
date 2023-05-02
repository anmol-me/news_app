import 'package:flutter/material.dart';
import 'package:news_app/common/constants.dart';

import '../common/enums.dart';

class AppTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextStyle? labelStyle;

  const AppTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: labelStyle,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: colorRed,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: colorRed,
          ),
        ),
      ),
      validator: (val) {
        if (controller.text.isEmpty) {
          return ErrorString.emptyField.value;
        } else {
          return null;
        }
      },
    );
  }
}
