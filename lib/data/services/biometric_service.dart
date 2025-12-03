import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    try {
      return await auth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) return false;

      final canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      return await auth.authenticate(
        localizedReason: 'Please authenticate to access Kanakupulla',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/Pattern as backup
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
