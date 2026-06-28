import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseField extends StatelessWidget {
  const BaseField({
    required this.keyboardType,
    required this.textInputAction,
    required this.controller,
    required this.focusNode,
    this.validator,
    this.onFieldSubmitted,
    this.inputFormatters,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(borderSide: .none);
    return SizedBox(
      width: 60,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        selectAllOnFocus: false,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        textAlign: .center,
        decoration: InputDecoration(
          border: border,
          focusedBorder: border,
          enabledBorder: border,
          disabledBorder: border,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const .symmetric(horizontal: 6),
        ),
        validator: validator,
        errorBuilder: (_, _) => const SizedBox.shrink(),
        onFieldSubmitted: onFieldSubmitted,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
