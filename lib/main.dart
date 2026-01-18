import 'package:flutter/material.dart';
import 'views/app_theme.dart';
import 'views/dashboard_view.dart';
import 'controllers/auth_controller.dart';

import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const WheelOfLifeApp());
}

class WheelOfLifeApp extends StatefulWidget {
  const WheelOfLifeApp({super.key});

  @override
  State<WheelOfLifeApp> createState() => _WheelOfLifeAppState();
}

class _WheelOfLifeAppState extends State<WheelOfLifeApp> {
  final AuthController _auth = AuthController();
  bool _isLocked = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final enabled = await _auth.isBiometricEnabled;
    if (enabled) {
      final success = await _auth.authenticate();
      setState(() {
        _isLocked = !success;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLocked = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(home: Scaffold(backgroundColor: AppTheme.background));
    }

    if (_isLocked) {
      return MaterialApp(
        theme: AppTheme.themeData,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 64, color: Colors.white54),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _checkAuth,
                  child: const Text(
                    "Unlock",
                    style: TextStyle(color: AppTheme.accentColor, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Wheel of Life',
      theme: AppTheme.themeData,
      home: const DashboardView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
