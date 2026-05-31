import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subby/app/common/widgets/base_field.dart';

class CidrField extends StatelessWidget {
  const CidrField({
    required this.controller,
    required this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return BaseField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: .done,
      keyboardType: .number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return '';
        return null;
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(2, maxLengthEnforcement: .enforced),
        FilteringTextInputFormatter.digitsOnly,
        TextInputFormatter.withFunction((previous, next) {
          final nextValue = next.text.trim();

          if (nextValue.isEmpty) return next;

          final parsedNextValue = int.tryParse(nextValue);

          if (parsedNextValue == null ||
              parsedNextValue < 0 ||
              parsedNextValue > 32) {
            return previous;
          }

          return next;
        }),
      ],
    );
  }
}
