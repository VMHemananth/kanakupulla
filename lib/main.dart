import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const KanakupullaApp(),
    ),
  );
}
