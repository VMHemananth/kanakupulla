import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_lock_provider.dart';

final sessionLockProvider = StateNotifierProvider<SessionLockNotifier, bool>((ref) {
  final isAppLockEnabled = ref.watch(appLockProvider);
  return SessionLockNotifier(isAppLockEnabled);
});

class SessionLockNotifier extends StateNotifier<bool> {
  final bool _isAppLockEnabled;

  SessionLockNotifier(this._isAppLockEnabled) : super(false) {
    if (_isAppLockEnabled) {
      state = true; // Lock initially if enabled
    }
  }

  void lock() {
    if (_isAppLockEnabled) {
      state = true;
    }
  }

  void unlock() {
    state = false;
  }
  
  // Update internal state if setting changes (though usually requires app restart or re-init to take full effect properly, 
  // but this helps if user toggles it while app is running)
  void updateSetting(bool isEnabled) {
    if (!isEnabled) {
      state = false;
    }
  }
}
