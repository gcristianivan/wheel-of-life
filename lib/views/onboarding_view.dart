import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'dashboard_view.dart';

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
          "Life is complex. We often get so caught up in the daily grind, chasing deadlines or running errands, that we lose sight of the big picture.\nThe Wheel of Life is a proven coaching tool that invites you to take a 'snapshot' of your existence. Instead of looking at your life as one big, overwhelming mix, we break it down into 8 core pillars. It helps you understand not just how you are doing, but how balanced you truly are.",
    },
    {
      "title": "The Metaphor",
      "body":
          "Imagine your life is a wheel. Each spoke represents an area like Health, Career, or Romance.\nIf you score high in Career but low in Health and Fun, your wheel becomes jagged and uneven. If you tried to drive a car with a wheel like that, the ride would be bumpy and uncomfortable. Your goal isn't necessarily to be perfect in every area, but to round out the wheel so your journey becomes smoother.",
    },
    {
      "title": "How LifeWheel Helps",
      "body":
          "'Wheel of Life' moves you from abstract guessing to visual clarity. Through a series of honest reflections, the app translates your current reality into a tangible shape. You won’t just feel your imbalances; you will see them. This immediate feedback highlights exactly where you are thriving and where you have 'dents,' turning a complex life into a clear, actionable roadmap.",
    },
    {
      "title": "The Goal",
      "body":
          "A balanced wheel doesn't mean doing everything at once. It means identifying the neglected areas that are dragging you down. By improving your lowest scores, you often find that other areas of your life improve automatically.",
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
        MaterialPageRoute(builder: (_) => const DashboardView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
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
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // You could add an illustration here based on the slide index
                        const SizedBox(height: 20),
                        Text(
                          _slides[index]["title"]!,
                          style: AppTheme.heading2.copyWith(fontSize: 28),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _slides[index]["body"]!,
                          style: AppTheme.bodyText.copyWith(fontSize: 16, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
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
                    color: _currentPage == index ? AppTheme.accentColor : Colors.white24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
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
                    _currentPage < _slides.length - 1 ? "Next" : "Get Started",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
