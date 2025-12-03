import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';

final appLockProvider = StateNotifierProvider<AppLockNotifier, bool>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return AppLockNotifier(settingsRepo);
});

class AppLockNotifier extends StateNotifier<bool> {
  final SettingsRepository _settingsRepository;

  AppLockNotifier(this._settingsRepository) : super(false) {
    _init();
  }

  void _init() {
    state = _settingsRepository.isAppLockEnabled();
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    await _settingsRepository.setAppLockEnabled(enabled);
    state = enabled;
  }
  
  bool get isEnabled => state;
}
