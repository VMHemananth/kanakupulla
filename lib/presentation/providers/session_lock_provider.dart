import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_lock_provider.dart';

final sessionLockProvider = StateNotifierProvider<SessionLockNotifier, bool>((ref) {
  return SessionLockNotifier(ref);
});

class SessionLockNotifier extends StateNotifier<bool> {
  final Ref ref;

  SessionLockNotifier(this.ref) : super(false) {
    // Initial check (Cold Start)
    final isEnabled = ref.read(appLockProvider);
    if (isEnabled) {
      state = true;
    }

    // Listen to setting changes
    ref.listen<bool>(appLockProvider, (previous, next) {
      if (next) {
        // User just enabled App Lock. 
        // They authenticated to do this, so we DON'T lock immediately.
        // We leave state as is (likely false).
      } else {
        // User disabled App Lock.
        // Ensure we are unlocked.
        state = false;
      }
    });
  }

  bool _isAuthenticating = false;

  void setAuthenticating(bool value) {
    _isAuthenticating = value;
  }

  void lock() {
    // Check current setting value
    if (ref.read(appLockProvider) && !_isAuthenticating) {
      state = true;
    }
  }

  void unlock() {
    state = false;
  }
  
  // No need for updateSetting, handled by listen
}
