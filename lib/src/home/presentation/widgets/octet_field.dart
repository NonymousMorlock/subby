import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subby/app/common/widgets/base_field.dart';

class OctetField extends StatelessWidget {
  const OctetField({
    required this.focusNode,
    required this.controller,
    this.nextFocusNode,
    this.previousFocusNode,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final FocusNode? previousFocusNode;

  @override
  Widget build(BuildContext context) {
    return BaseField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: .next,
      keyboardType: .number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return '';
        return null;
      },
      onFieldSubmitted: (_) => nextFocusNode?.requestFocus(),
      inputFormatters: [
        LengthLimitingTextInputFormatter(4, maxLengthEnforcement: .enforced),
        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
        TextInputFormatter.withFunction((previous, next) {
          const blank = '\u200B';
          final nextValue = next.text.trim().replaceAll(blank, '');
          final previousValue = previous.text.trim().replaceAll(blank, '');

          final nextWithBlank = blank + nextValue;
          final previousWithBlank = blank + previousValue;

          final previousEditingValue = previous.copyWith(
            text: previousWithBlank,
            selection: .collapsed(offset: previousWithBlank.length),
          );
          final nextEditingValue = previous.copyWith(
            text: nextWithBlank,
            selection: .collapsed(offset: nextWithBlank.length),
          );

          if (nextValue.isEmpty && previousWithBlank == blank) {
            unawaited(
              Future.microtask(() => previousFocusNode?.requestFocus()),
            );
            return previousEditingValue;
          }

          if (nextValue.endsWith('.')) {
            unawaited(Future.microtask(() => nextFocusNode?.requestFocus()));
            return previousEditingValue;
          }

          if (nextValue.length > 3) return previousEditingValue;

          final parsedNextValue = int.tryParse(nextValue);
          if (parsedNextValue == null || parsedNextValue > 255) {
            return previousEditingValue;
          }

          if (nextValue.length == 3 &&
              nextValue.length > previousValue.length) {
            unawaited(Future.microtask(() => nextFocusNode?.requestFocus()));
          }
          return nextEditingValue;
        }),
      ],
    );
  }
}
