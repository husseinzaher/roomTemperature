import 'package:flutter/material.dart';

/// {@template primary_button}
/// A filled button wrapper with a built-in loading state.
///
/// While [isLoading] is `true` the [label] is replaced by a small
/// [CircularProgressIndicator] and the button is disabled.
/// {@endtemplate}
class PrimaryButton extends StatelessWidget {
  /// {@macro primary_button}
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
  });

  /// The button's label text.
  final String label;

  /// Called when the button is pressed. Ignored while [isLoading] is true.
  final VoidCallback? onPressed;

  /// Whether to show a loading spinner instead of the label.
  final bool isLoading;

  /// An optional leading icon, hidden while [isLoading] is true.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.onPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );
  }
}
