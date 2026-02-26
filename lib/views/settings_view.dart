import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/data_transfer_service.dart';
import '../controllers/database_service.dart';
import '../controllers/action_item_service.dart';
import 'app_theme.dart';
import 'onboarding_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final AuthController _auth = AuthController();
  final DataTransferService _dataService = DataTransferService();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (false) ...[
                    SwitchListTile(
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
                    const Divider(color: Colors.white24),
                  ],
                  ListTile(
                    leading:
                        const Icon(Icons.upload_file, color: Colors.white70),
                    title: Text(
                      "Export Data",
                      style: AppTheme.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.white54),
                    onTap: () async {
                      try {
                        final file = await _dataService.exportData();
                        if (file != null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Data exported successfully!")),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Export failed: $e")),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    leading: const Icon(Icons.download, color: Colors.white70),
                    title: Text(
                      "Import Data",
                      style: AppTheme.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.white54),
                    onTap: () async {
                      bool? overwrite = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1C1B33),
                          title:
                              Text("Import Options", style: AppTheme.heading2),
                          content: Text(
                              "Do you want to overwrite your existing data, or merge the imported data with it?",
                              style: AppTheme.bodyText),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text("Merge",
                                  style:
                                      TextStyle(color: AppTheme.accentColor)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Overwrite",
                                  style: TextStyle(color: Colors.redAccent)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, null),
                              child: const Text("Cancel",
                                  style: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                      );

                      if (overwrite != null && mounted) {
                        try {
                          final success = await _dataService.importData(
                              overwrite: overwrite);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Data imported successfully!")),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Import failed: $e")),
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    leading:
                        const Icon(Icons.info_outline, color: Colors.white70),
                    title: Text(
                      "About Life Wheel",
                      style: AppTheme.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.white54),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingView(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    leading: const Icon(Icons.delete_forever,
                        color: Colors.redAccent),
                    title: Text(
                      "Clear All Data",
                      style: AppTheme.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.white54),
                    onTap: () async {
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1C1B33),
                          title: Text("Clear All Data",
                              style: AppTheme.heading2
                                  .copyWith(color: Colors.redAccent)),
                          content: Text(
                              "Are you sure you want to permanently delete all Life Wheel history and Action Items? This action cannot be undone.",
                              style: AppTheme.bodyText),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel",
                                  style: TextStyle(color: Colors.white70)),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Colors.redAccent.withOpacity(0.1),
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Delete Everything",
                                  style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        try {
                          await DatabaseService.instance.clearData();
                          await ActionItemService.instance.clearData();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("All data has been cleared."),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Failed to clear data: $e")),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
