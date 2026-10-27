import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mylife_field_shell.dart';
import 'mylife_form_tokens.dart';

class MyLifeTextField extends StatelessWidget {
  const MyLifeTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.errorText,
    this.helperText,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.maxLength,
    this.focusNode,
    this.onFieldSubmitted,
  }) : assert(controller == null || initialValue == null,
            'Use controller or initialValue, not both.');

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool required;
  final String? errorText;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;

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
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: 10)
              ],
              Expanded(
                child: TextFormField(
                  controller: controller,
                  initialValue:
                      controller == null ? field.value ?? initialValue : null,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  obscureText: obscureText,
                  enabled: enabled,
                  readOnly: readOnly,
                  onChanged: (value) {
                    field.didChange(value);
                    onChanged?.call(value);
                  },
                  onTap: onTap,
                  onFieldSubmitted: onFieldSubmitted,
                  inputFormatters: inputFormatters,
                  maxLength: maxLength,
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
              if (suffixIcon != null) ...[
                const SizedBox(width: 8),
                suffixIcon!
              ],
            ],
          ),
        ),
      ),
    );
  }
}
