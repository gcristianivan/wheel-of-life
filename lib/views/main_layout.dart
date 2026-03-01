import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'dashboard_view.dart';
import 'history_view.dart';
import 'goals_view.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
        DashboardView(
          key: UniqueKey(), // Force rebuild
          onNavigateToGoals: () {
            setState(() {
              _currentIndex = 2; // Switch to GoalsView
            });
          },
        ),
        HistoryView(
            key: UniqueKey()), // Force rebuild on tab switch to reload data
        GoalsView(key: UniqueKey()),
      ];

  @override
  Widget build(BuildContext context) {
    // Determine nav bar background color depending on current tab
    // We want the nav bar to blend with the background of the pages
    final navThemeColor = const Color(0xFF1C1B33);

    return Scaffold(
      extendBody:
          true, // Allows body to extend behind bottom nav for blur effect if needed
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navThemeColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            backgroundColor: navThemeColor,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.accentColor,
            unselectedItemColor: Colors.white54,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timeline_rounded),
                label: 'Evolution',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.track_changes_rounded),
                label: 'Goals',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
