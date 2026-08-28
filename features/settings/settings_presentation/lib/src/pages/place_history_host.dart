import 'package:flutter/foundation.dart';

/// Host callbacks for locally stored place history, injected by the app.
class PlaceHistoryHost {
  /// Creates a place-history host.
  const PlaceHistoryHost({
    required this.onOpenPlaces,
    required this.onDeleteAll,
    required this.onEnabledChanged,
  });

  /// Opens the Places History screen.
  final VoidCallback onOpenPlaces;

  /// Deletes every stored place and visit after the user confirms.
  final Future<void> Function() onDeleteAll;

  /// Persists the collection toggle. Existing history is kept.
  final Future<void> Function({required bool enabled}) onEnabledChanged;
}
