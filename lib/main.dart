import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workly/firebase_options.dart';
import 'main_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'models/user_profile.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WorklyApp());
}

class WorklyApp extends StatefulWidget {
  const WorklyApp({super.key});

  @override
  State<WorklyApp> createState() => _WorklyAppState();
}

class _WorklyAppState extends State<WorklyApp> {
  @override
  void initState() {
    super.initState();
    ThemeManager().init();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager(),
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Workly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = snapshot.data ?? false;
        if (!isLoggedIn) {
          return const LoginScreen();
        }

        // If logged in, check onboarding status
        return FutureBuilder<bool>(
          future: _checkOnboarding(),
          builder: (context, onboardSnapshot) {
            if (onboardSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final isOnboarded = onboardSnapshot.data ?? false;
            return isOnboarded ? const MainWrapper() : const OnboardingScreen();
          },
        );
      },
    );
  }

  Future<bool> _checkOnboarding() async {
    final authService = AuthService();
    final username = await authService.getCurrentUserName();
    if (username == null) return false;

    // We assume username is the key. In real app, we need consistent ID.
    // Re-polishing: AuthService uses 'current_user' pref to store username.
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('current_user');

    if (currentUserId != null) {
      final profileJson = prefs.getString('profile_$currentUserId');
      if (profileJson != null) {
        final profile = UserProfile.fromJson(jsonDecode(profileJson));
        return profile.onboardingCompleted;
      }
    }
    return false;
  }
}
