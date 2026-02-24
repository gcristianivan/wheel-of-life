import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'main_layout.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      "title": "The Concept",
      "body":
          "Life is more than just a daily grind. We break your world into 8 core pillars, giving you a high-level snapshot of your existence. Stop guessing and start seeing the big picture.",
      "image": "assets/images/concept.png"
    },
    {
      "title": "The Metaphor",
      "body":
          "Think of your life as a wheel. If your Career is soaring but Health is neglected, your wheel becomes jagged. A bumpy wheel makes for a rough ride: we help you round it out for a smoother journey.",
      "image": "assets/images/metaphor.png"
    },
    {
      "title": "How LifeWheel Helps",
      "body":
          "We turn abstract feelings into visual clarity. By mapping your reflections into a tangible shape, you can instantly spot the \"dents\" in your life and turn them into an actionable roadmap.",
      "image": "assets/images/clarity.png"
    },
    {
      "title": "The Goal",
      "body":
          "Balance isn't about being perfect; it’s about alignment. By identifying and lifting your lowest scores, you'll find that the rest of your life often improves automatically.",
      "image": "assets/images/goal.png"
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Image.asset(
                _slides[_currentPage]["image"]!,
                key: ValueKey<int>(_currentPage),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _slides[index]["title"]!,
                              style: AppTheme.heading2.copyWith(fontSize: 32),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _slides[index]["body"]!,
                              style: AppTheme.bodyText.copyWith(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? AppTheme.accentColor
                            : Colors.white24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Text(
                        _currentPage < _slides.length - 1
                            ? "Next"
                            : "Get Started",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
