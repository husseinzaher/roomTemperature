import 'package:flutter/material.dart';

/// {@template app_text_field}
/// A [TextFormField] with the app's consistent decoration.
///
/// Supports [obscureText] with a visibility-toggle suffix icon for password
/// fields, and surfaces [errorText] through the field's error slot.
/// {@endtemplate}
class AppTextField extends StatefulWidget {
  /// {@macro app_text_field}
  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.textInputAction,
    this.enabled = true,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// The floating label text.
  final String? labelText;

  /// An error message shown below the field.
  final String? errorText;

  /// The type of keyboard to show.
  final TextInputType? keyboardType;

  /// Whether to obscure the text, with a toggle to reveal it.
  final bool obscureText;

  /// Called whenever the text changes.
  final ValueChanged<String>? onChanged;

  /// The action button to show on the keyboard.
  final TextInputAction? textInputAction;

  /// Whether the field is enabled.
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText && _obscured,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        errorText: widget.errorText,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}
