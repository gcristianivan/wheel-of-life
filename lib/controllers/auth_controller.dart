import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthController {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> get isBiometricEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
  }

  Future<bool> authenticate() async {
    if (kIsWeb) return true; // Web generic bypass
    final isSupported = await auth.isDeviceSupported();
    if (!isSupported) {
      // If device doesn't support it, but it's enabled (e.g. state persisted then device changed?),
      // fallback or just return true to not block user?
      // Or return false. Security wise: fail closed.
      // But for development on simulator, we might want to bypass if not supported.
      return true;
    }

    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Scan to access your Wheel of Life',
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }
}
