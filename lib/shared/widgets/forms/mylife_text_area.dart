import 'package:flutter/material.dart';
import 'mylife_field_shell.dart';
import 'mylife_form_tokens.dart';

class MyLifeTextArea extends StatelessWidget {
  const MyLifeTextArea({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.enabled = true,
    this.required = false,
    this.errorText,
    this.helperText,
    this.validator,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 5,
    this.maxLength,
    this.textInputAction = TextInputAction.newline,
  }) : assert(controller == null || initialValue == null,
            'Use controller or initialValue, not both.');

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final bool enabled;
  final bool required;
  final String? errorText;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final tokens = MyLifeFormTokens.of(context);
    return FormField<String>(
      initialValue: controller?.text ?? initialValue,
      enabled: enabled,
      validator: validator,
      builder: (field) => MyLifeFieldShell(
        label: label,
        required: required,
        enabled: enabled,
        errorText: errorText ?? field.errorText,
        helperText: helperText,
        minHeight: 112,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: TextFormField(
          controller: controller,
          initialValue: controller == null ? field.value ?? initialValue : null,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          onChanged: (value) {
            field.didChange(value);
            onChanged?.call(value);
          },
          textInputAction: textInputAction,
          style: TextStyle(
              color: tokens.fieldText,
              fontSize: 15,
              fontWeight: FontWeight.w500),
          cursorColor: tokens.fieldFocusBorder,
          decoration: InputDecoration.collapsed(
            hintText: hint,
            hintStyle: TextStyle(
                color: tokens.fieldPlaceholder,
                fontSize: 15,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
