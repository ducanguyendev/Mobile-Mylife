import 'package:flutter/material.dart';
import 'mylife_form_tokens.dart';

class MyLifeFieldShell extends StatefulWidget {
  const MyLifeFieldShell({
    super.key,
    required this.child,
    this.label,
    this.helperText,
    this.errorText,
    this.required = false,
    this.enabled = true,
    this.minHeight = 58,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool required;
  final bool enabled;
  final double minHeight;
  final EdgeInsets contentPadding;

  @override
  State<MyLifeFieldShell> createState() => _MyLifeFieldShellState();
}

class _MyLifeFieldShellState extends State<MyLifeFieldShell> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = MyLifeFormTokens.of(context);
    final hasError = widget.errorText?.isNotEmpty ?? false;
    final borderColor = hasError
        ? tokens.fieldError
        : _focused
            ? tokens.fieldFocusBorder
            : tokens.fieldBorder;

    return Focus(
      onFocusChange: (focused) {
        if (_focused != focused) setState(() => _focused = focused);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label?.isNotEmpty ?? false) ...[
            Text.rich(
              TextSpan(
                text: widget.label,
                children: widget.required
                    ? [
                        TextSpan(
                            text: ' *',
                            style: TextStyle(color: tokens.fieldError))
                      ]
                    : const [],
              ),
              style: TextStyle(
                  color: tokens.fieldLabel,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
          ],
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            constraints: BoxConstraints(minHeight: widget.minHeight),
            padding: widget.contentPadding,
            decoration: BoxDecoration(
              color: widget.enabled
                  ? tokens.fieldBackground
                  : tokens.fieldDisabledBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: _focused && !hasError
                  ? [
                      BoxShadow(
                          color: tokens.fieldFocusRing,
                          blurRadius: 0,
                          spreadRadius: 2)
                    ]
                  : const [],
            ),
            child: IconTheme(
              data: IconThemeData(color: tokens.fieldLabel, size: 18),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                    color: tokens.fieldText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
                child: widget.child,
              ),
            ),
          ),
          if (hasError || (widget.helperText?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.errorText ?? widget.helperText!,
                style: TextStyle(
                  color: hasError ? tokens.fieldError : tokens.fieldLabel,
                  fontSize: 12,
                  fontWeight: hasError ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
