import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('Initialize this provider in main');
});

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  Future<void> saveUser(UserModel user) async {
    await _prefs.setString('userName', user.name);
    await _prefs.setString('userEmail', user.email);
    await _prefs.setStringList('categories', user.categories);
    await _prefs.setInt('workingDays', user.workingDaysPerMonth);
    await _prefs.setInt('workingHours', user.workingHoursPerDay);
    if (user.profilePicPath != null) {
      await _prefs.setString('profilePicPath', user.profilePicPath!);
    }
    if (user.phoneNumber != null) {
      await _prefs.setString('phoneNumber', user.phoneNumber!);
    }
  }

  UserModel getUser() {
    final name = _prefs.getString('userName') ?? '';
    final email = _prefs.getString('userEmail') ?? '';
    final categories = _prefs.getStringList('categories') ?? 
        ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health', 'Education', 'Others'];
    final workingDays = _prefs.getInt('workingDays') ?? 22;
    final workingHours = _prefs.getInt('workingHours') ?? 8;
    final profilePicPath = _prefs.getString('profilePicPath');
    final phoneNumber = _prefs.getString('phoneNumber');

    return UserModel(
      name: name,
      email: email,
      categories: categories,
      workingDaysPerMonth: workingDays,
      workingHoursPerDay: workingHours,
      profilePicPath: profilePicPath,
      phoneNumber: phoneNumber,
    );
  }

  Future<void> savePin(String pin) async {
    await _prefs.setString('userPin', pin);
  }

  String? getPin() {
    return _prefs.getString('userPin');
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _prefs.setBool('isLoggedIn', isLoggedIn);
  }

  bool isLoggedIn() {
    return _prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    await _prefs.setBool('isAppLockEnabled', enabled);
  }

  bool isAppLockEnabled() {
    return _prefs.getBool('isAppLockEnabled') ?? false;
  }
}
