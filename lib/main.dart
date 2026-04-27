import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workly/firebase_options.dart';
import 'main_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        // If logged in, check onboarding status in Firestore
        return FutureBuilder<bool>(
          future: _checkOnboarding(user.uid),
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

  Future<bool> _checkOnboarding(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('onboardingCompleted')) {
          final isOnboarded = data['onboardingCompleted'] == true;
          if (isOnboarded) {
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint('Firestore read error checking onboarding: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('profile_$uid');

    // For MVP we still check local preferences for onboarding state since UserProfile model relies on it.
    // In a full implementation, this should be moved to the Firestore `users` doc as well.
    if (profileJson != null) {
      try {
        final profile = UserProfile.fromJson(jsonDecode(profileJson));
        return profile.onboardingCompleted;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
