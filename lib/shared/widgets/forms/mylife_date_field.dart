import 'package:flutter/material.dart';
import 'mylife_field_shell.dart';
import 'mylife_form_tokens.dart';

class MyLifeDateField extends StatelessWidget {
  const MyLifeDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint = 'DD/MM/YYYY',
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.required = false,
    this.errorText,
    this.helperText,
    this.initialDate,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final bool required;
  final String? errorText;
  final String? helperText;
  final DateTime? initialDate;

  String _format(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().padLeft(4, '0')}';

  Future<void> _pickDate(BuildContext context) async {
    if (!enabled) return;
    final today = DateTime.now();
    final min = firstDate ?? DateTime(1900);
    final max = lastDate ?? DateTime(2200, 12, 31);
    final selected = await showDatePicker(
      context: context,
      initialDate: value ?? initialDate ?? today,
      firstDate: min,
      lastDate: max,
    );
    if (selected != null) {
      onChanged(DateTime(selected.year, selected.month, selected.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MyLifeFormTokens.of(context);
    return MyLifeFieldShell(
      label: label,
      required: required,
      enabled: enabled,
      errorText: errorText,
      helperText: helperText,
      child: SizedBox(
        height: 56,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? () => _pickDate(context) : null,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null ? hint : _format(value!),
                    style: TextStyle(
                      color: value == null
                          ? tokens.fieldPlaceholder
                          : tokens.fieldText,
                      fontSize: 15,
                      fontWeight:
                          value == null ? FontWeight.w400 : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_outlined,
                    color: tokens.fieldLabel, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
