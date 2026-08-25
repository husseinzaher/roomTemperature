import 'package:flutter/material.dart';

/// {@template auth_error_banner}
/// A simple error banner shown below an auth form's fields when a
/// request fails.
/// {@endtemplate}
class AuthErrorBanner extends StatelessWidget {
  /// {@macro auth_error_banner}
  const AuthErrorBanner({required this.message, super.key});

  /// The message to display.
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
