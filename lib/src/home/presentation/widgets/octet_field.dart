import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subby/app/common/widgets/base_field.dart';
import 'package:subby/core/constants/core_constants.dart';

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
        final normalisedValue = value?.trim().replaceAll(
          CoreConstants.emptyCharacter,
          '',
        );
        if (normalisedValue == null || normalisedValue.isEmpty) return '';
        return null;
      },
      onFieldSubmitted: (_) => nextFocusNode?.requestFocus(),
      inputFormatters: [
        LengthLimitingTextInputFormatter(5, maxLengthEnforcement: .enforced),
        TextInputFormatter.withFunction((previous, next) {
          final allowedPattern = RegExp('[0-9.]');
          const blank = CoreConstants.emptyCharacter;
          final nextValue = next.text.trim().replaceAll(blank, '');
          final previousValue = previous.text.trim().replaceAll(blank, '');

          for (final char in nextValue.characters) {
            if (!allowedPattern.hasMatch(char)) {
              log(
                'Invalid character entered: $char, reverting to previous value',
                name: 'OctetFieldFormatter',
              );
              return previous;
            }
          }

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
            log(
              'Backspace on empty field, moving focus to previous field',
              name: 'OctetFieldFormatter',
            );
            if (previousFocusNode != null) {
              log(
                'Requesting focus on previous field',
                name: 'OctetFieldFormatter',
              );
              unawaited(
                Future.microtask(() => previousFocusNode!.requestFocus()),
              );
            }
            return previousEditingValue;
          }

          if (nextValue.endsWith('.')) {
            log(
              'Dot entered, moving focus to next field',
              name: 'OctetFieldFormatter',
            );
            unawaited(Future.microtask(() => nextFocusNode?.requestFocus()));
            return previousEditingValue;
          }

          if (nextValue.length > 3) {
            log(
              'Octet value too long: $nextValue, reverting to previous value',
              name: 'OctetFieldFormatter',
            );
            unawaited(Future.microtask(() => nextFocusNode?.requestFocus()));
            return previousEditingValue;
          }

          final parsedNextValue = int.tryParse(nextValue);
          if (nextValue.isNotEmpty &&
              (parsedNextValue == null || parsedNextValue > 255)) {
            log(
              'Invalid octet value: $nextValue, reverting to previous value',
              name: 'OctetFieldFormatter',
            );
            return previousEditingValue;
          }

          if (nextValue.length == 3) {
            log(
              'Octet complete, moving focus to next field',
              name: 'OctetFieldFormatter',
            );
            unawaited(Future.microtask(() => nextFocusNode?.requestFocus()));
          } else if (nextValue.length == 2) {
            final firstCodeUnit = nextValue.codeUnitAt(0);
            final secondCodeUnit = nextValue.codeUnitAt(1);

            if (firstCodeUnit > 50 ||
                (firstCodeUnit == 50 && secondCodeUnit > 53)) {
              log(
                'Octet value will exceed 255, moving focus to next field',
                name: 'OctetFieldFormatter',
              );
              unawaited(Future.microtask(() => nextFocusNode?.requestFocus()));
            }
          }
          log(
            'Accepting octet value: $nextValue',
            name: 'OctetFieldFormatter',
          );
          return nextEditingValue;
        }),
      ],
    );
  }
}
