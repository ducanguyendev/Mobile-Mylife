import 'package:flutter/material.dart';
import 'mylife_field_shell.dart';
import 'mylife_form_tokens.dart';

class MyLifeSelectField<T> extends StatelessWidget {
  const MyLifeSelectField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.enabled = true,
    this.required = false,
    this.errorText,
    this.helperText,
    this.validator,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? hint;
  final bool enabled;
  final bool required;
  final String? errorText;
  final String? helperText;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    final tokens = MyLifeFormTokens.of(context);
    return FormField<T>(
      initialValue: value,
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
          child: DropdownButtonFormField<T>(
            initialValue: field.value,
            isExpanded: true,
            icon: Icon(Icons.expand_more, color: tokens.fieldLabel, size: 18),
            style: TextStyle(
                color: tokens.fieldText,
                fontSize: 15,
                fontWeight: FontWeight.w500),
            dropdownColor: tokens.fieldBackground,
            hint: hint == null
                ? null
                : Text(hint!,
                    style: TextStyle(
                        color: tokens.fieldPlaceholder, fontSize: 15)),
            decoration: const InputDecoration.collapsed(hintText: ''),
            items: items,
            onChanged: enabled
                ? (next) {
                    field.didChange(next);
                    onChanged?.call(next);
                  }
                : null,
          ),
        ),
      ),
    );
  }
}
