import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  setupRequired,
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return AuthNotifier(settingsRepo);
});

class AuthNotifier extends StateNotifier<AuthStatus> {
  final SettingsRepository _repository;

  AuthNotifier(this._repository) : super(AuthStatus.unauthenticated) {
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final pin = _repository.getPin();
    if (pin == null) {
      state = AuthStatus.setupRequired;
    } else {
      // If PIN exists, we start as unauthenticated (need to login)
      // unless we want to persist login state across restarts (optional, but safer to require login)
      state = AuthStatus.unauthenticated; 
    }
  }

  Future<void> setPin(String pin) async {
    await _repository.savePin(pin);
    state = AuthStatus.authenticated; // Auto-login after setup
  }

  Future<bool> login(String pin) async {
    final storedPin = _repository.getPin();
    if (storedPin == pin) {
      state = AuthStatus.authenticated;
      return true;
    }
    return false;
  }

  void logout() {
    state = AuthStatus.unauthenticated;
  }
}
