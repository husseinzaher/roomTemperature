import 'package:flutter/material.dart';

/// {@template loading_view}
/// A centered loading spinner, optionally with a message below it.
/// {@endtemplate}
class LoadingView extends StatelessWidget {
  /// {@macro loading_view}
  const LoadingView({super.key, this.message});

  /// An optional message shown below the spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
