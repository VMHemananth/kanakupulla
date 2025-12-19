import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/setup_screen.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/lock_screen.dart';

import 'presentation/providers/session_lock_provider.dart';

class KanakupullaApp extends ConsumerStatefulWidget {
  const KanakupullaApp({super.key});

  @override
  ConsumerState<KanakupullaApp> createState() => _KanakupullaAppState();
}

class _KanakupullaAppState extends ConsumerState<KanakupullaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(sessionLockProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(authProvider);
    final themeState = ref.watch(themeProvider);
    final isLocked = ref.watch(sessionLockProvider);

    return MaterialApp(
      title: 'Kanakupulla',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(themeState.seedColor),
      darkTheme: AppTheme.darkTheme(themeState.seedColor),
      themeMode: themeState.mode,
      home: _getHomeScreen(authStatus),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (isLocked && authStatus == AuthStatus.authenticated)
              const LockScreen(),
          ],
        );
      },
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

    }
  }
}
