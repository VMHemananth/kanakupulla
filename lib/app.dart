import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/setup_screen.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';

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
      home: _getHomeScreen(authStatus),
    );
  }

  Widget _getHomeScreen(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        return const DashboardScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.setupRequired:
        return const SetupScreen();
      default:
        return const LoginScreen();
    }
  }
}
