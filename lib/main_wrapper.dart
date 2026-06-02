import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
// import 'screens/analytics_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_list_screen.dart';
import 'l10n/app_localizations.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    // const AnalyticsScreen(), // Disabled for testing
    const HistoryScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (!didPop) {
          setState(() {
            _currentIndex = 0; // Go back to Home tab if not on Home tab
          });
        }
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            height: 70,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.swipe_rounded),
                selectedIcon: const Icon(Icons.swipe_rounded),
                label: l10n.homeTab,
              ),
              NavigationDestination(
                icon: const Icon(Icons.history_rounded),
                selectedIcon: const Icon(Icons.history_edu_rounded),
                label: l10n.historyTab,
              ),
              NavigationDestination(
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: const Icon(Icons.chat_bubble_rounded),
                label: l10n.chatsTab,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: l10n.profileTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
