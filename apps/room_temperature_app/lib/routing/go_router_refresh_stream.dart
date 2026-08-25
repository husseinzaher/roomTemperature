import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns a [Stream] into a [Listenable] so it can drive `GoRouter`'s
/// `refreshListenable`, re-running redirects whenever the stream emits
/// (e.g. on every auth-state change).
class GoRouterRefreshStream extends ChangeNotifier {
  /// Creates a [GoRouterRefreshStream] that notifies on every [stream]
  /// event.
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
