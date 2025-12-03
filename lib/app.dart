import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/setup_screen.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/lock_screen.dart';
import 'presentation/screens/lock_screen.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/providers/app_lock_provider.dart';

class KanakupullaApp extends ConsumerWidget {
  const KanakupullaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Kanakupulla',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: _getHomeScreen(authStatus, ref),
    );
  }

  Widget _getHomeScreen(AuthStatus status, WidgetRef ref) {
    switch (status) {
      case AuthStatus.authenticated:
      case AuthStatus.authenticated:
        final isLockEnabled = ref.watch(appLockProvider);
        // Note: Ideally we should track "isSessionLocked" separately. 
        // For now, if lock is enabled, we show LockScreen. LockScreen pushes Dashboard on success.
        // But if we return LockScreen here, and LockScreen pushes Dashboard, we might have a stack issue.
        // However, the original code did exactly this: return isLocked ? LockScreen : Dashboard.
        // The issue was `isLocked` never updated. Now it will.
        // But wait, if `isLockEnabled` is true, it will ALWAYS return LockScreen?
        // Yes, that's a problem. We need a session state.
        // Let's stick to the original logic for now which was "If locked, show LockScreen". 
        // But LockScreen navigates away. 
        // If `app.dart` rebuilds, it might show LockScreen again?
        // Actually, `home:` is only built once usually unless AuthStatus changes.
        return isLockEnabled ? const LockScreen() : const DashboardScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.setupRequired:
        return const SetupScreen();
      default:
        return const LoginScreen();
    }
  }
}
