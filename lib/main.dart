import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'theme/language_manager.dart';
import 'l10n/app_localizations.dart';

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
    LanguageManager().init();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager(),
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LanguageManager(),
          builder: (context, locale, _) {
            return MaterialApp(
              title: 'Workly',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: LanguageManager.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const AuthWrapper(),
            );
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Cache the future per uid so we don't re-run the check on every stream event.
  // On web, each stream emit would otherwise create a new Future, causing a brief
  // "false" window that redirects the user to onboarding on page refresh.
  Future<bool>? _cachedFuture;
  String? _cachedUid;

  Future<bool> _getOnboardingFuture(String uid) {
    if (_cachedFuture == null || _cachedUid != uid) {
      _cachedUid = uid;
      _cachedFuture = _checkOnboarding(uid);
    }
    return _cachedFuture!;
  }

  /// Check onboarding status.
  /// Fast-path: SharedPreferences (localStorage on web) is checked first — instant,
  /// no network request. Only falls through to Firestore if local data is missing.
  Future<bool> _checkOnboarding(String uid) async {
    // ── 1. Fast path: check local storage (instant on web) ──────────────────
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('profile_$uid');
      if (profileJson != null) {
        final profile = UserProfile.fromJson(jsonDecode(profileJson));
        if (profile.onboardingCompleted) return true;
      }
    } catch (_) {}

    // ── 2. Slow path: check Firestore ────────────────────────────────────────
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['onboardingCompleted'] == true) {
          // Back-fill local cache so next refresh is instant
          final prefs = await SharedPreferences.getInstance();
          final existing = prefs.getString('profile_$uid');
          if (existing == null) {
            // Build a minimal profile just to persist the flag locally
            final minimal = UserProfile(
              onboardingCompleted: true,
              fullName: data['fullName'] ?? '',
              email: data['email'] ?? '',
            );
            await prefs.setString(
                'profile_$uid', jsonEncode(minimal.toJson()));
          }
          return true;
        }
      }
    } catch (e) {
      debugPrint('Firestore onboarding check error: $e');
    }

    return false;
  }

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
          // Reset cache when user logs out
          _cachedFuture = null;
          _cachedUid = null;
          return const LoginScreen();
        }

        return FutureBuilder<bool>(
          future: _getOnboardingFuture(user.uid),
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
}
