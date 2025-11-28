import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/settings_repository.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UserNotifier(repository);
});

class UserNotifier extends StateNotifier<UserModel> {
  final SettingsRepository _repository;

  UserNotifier(this._repository) : super(_repository.getUser());

  Future<void> updateUser(UserModel user) async {
    await _repository.saveUser(user);
    state = user;
  }
}
