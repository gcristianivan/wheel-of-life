import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import 'app_theme.dart';

class PaywallView extends StatefulWidget {
  const PaywallView({super.key});

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<PaywallView> {
  final AuthController _authController = AuthController();
  bool _isLoading = false;
  int _selectedPlanIndex = 1; // Default to Annual

  void _subscribe() async {
    setState(() => _isLoading = true);
    // Mock subscription process
    await Future.delayed(const Duration(seconds: 1));
    await _authController.setPremium(true);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Welcome to Premium!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Go back
    }
  }

  void _restorePurchases() async {
    setState(() => _isLoading = true);
    // Mock restore
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous purchases found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accentColor))
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with close button
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        'Unlock Your\nFull Potential',
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Go Premium to track your evolution, compare past assessments, and secure your personal data.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Features List
                      _buildFeatureItem(Icons.timeline, 'Unlimited Assessments',
                          'Track your life continuously'),
                      _buildFeatureItem(
                          Icons.compare_arrows,
                          'Historical Comparisons',
                          'See how much you\'ve grown'),
                      _buildFeatureItem(Icons.ssid_chart, 'Evolution Tracking',
                          'Visualize your life balance trends over time'),
                      _buildFeatureItem(
                          Icons.flag_outlined,
                          'Custom Goals setting',
                          'Set and track specific action items'),

                      const SizedBox(height: 48),

                      // Subscription Options (Mocked)
                      _buildPackageOption(
                        index: 0,
                        title: 'Monthly',
                        subtitle: 'Cancel anytime',
                        priceString: '\$0.99/mo',
                      ),
                      const SizedBox(height: 12),
                      _buildPackageOption(
                        index: 1,
                        title: 'Annual',
                        subtitle: 'Save 15% (Billed annually)',
                        priceString: '\$9.99/yr',
                      ),
                      const SizedBox(height: 12),
                      _buildPackageOption(
                        index: 2,
                        title: 'Lifetime',
                        subtitle: 'Pay once, yours forever',
                        priceString: '\$29.99',
                      ),

                      const SizedBox(height: 24),

                      // CTA
                      ElevatedButton(
                        onPressed: _subscribe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Start Subscription',
                          style: GoogleFonts.inter(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: _restorePurchases,
                        child: Text('Restore Purchases',
                            style: GoogleFonts.inter(color: Colors.white54)),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOption({
    required int index,
    required String title,
    required String subtitle,
    required String priceString,
  }) {
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentColor.withOpacity(0.15)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentColor
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                      color: isSelected ? Colors.white70 : Colors.white54,
                      fontSize: 14),
                ),
              ],
            ),
            Text(
              priceString,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: isSelected ? AppTheme.accentColor : Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
