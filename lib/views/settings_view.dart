import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'app_theme.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final AuthController _auth = AuthController();
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _auth.isBiometricEnabled;
    setState(() {
      _biometricsEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Settings", style: AppTheme.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AppTheme.glassCard(
              child: SwitchListTile(
                title: Text(
                  "Biometric Lock",
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Require FaceID/Fingerprint to open app",
                  style: AppTheme.bodyText.copyWith(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
                value: _biometricsEnabled,
                activeThumbColor: AppTheme.accentColor,
                onChanged: (val) async {
                  await _auth.setBiometricEnabled(val);
                  setState(() {
                    _biometricsEnabled = val;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
