import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/user_profile.dart'; // For UserPreferences
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../main_wrapper.dart';
import 'steps/onboarding_step_1_experience.dart';
import 'steps/onboarding_step_2_categories.dart';
import 'steps/onboarding_step_3_urgency.dart';
import 'steps/onboarding_step_4_salary.dart';
import 'steps/onboarding_step_5_priorities.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  // Draft State
  UserPreferences _preferences = UserPreferences();

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    // TODO: Load draft from SharedPreferences if exists for resilience
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    } else {
      Navigator.of(context)
          .pop(); // Back from onboarding (shouldn't happen often)
    }
  }

  bool _isStepValid() {
    switch (_currentPage) {
      case 0: // Experience
        return _preferences.experienceLevel.isNotEmpty;
      case 1: // Categories
        return _preferences.jobCategories.isNotEmpty &&
            _preferences.jobCategories.length <= 3;
      case 2: // Urgency
        return _preferences.jobUrgency.isNotEmpty;
      case 3: // Salary
        return _preferences.salaryMin <= _preferences.salaryMax;
      case 4: // Priorities
        return _preferences.jobPriorities.length == 3;
      default:
        return false;
    }
  }

  Future<void> _finishOnboarding() async {
    final authService = AuthService();
    // Identifier used for profile key
    final userDetails = await authService.getCurrentUserDetails();
    final prefs = await SharedPreferences.getInstance();

    final authUser = FirebaseAuth.instance.currentUser;
    final currentUserId = authUser?.uid;

    if (currentUserId != null) {
      // Load existing profile or create new
      UserProfile profile = UserProfile();
      final profileKey = 'profile_$currentUserId';
      final profileJson = prefs.getString(profileKey);

      if (profileJson != null) {
        profile = UserProfile.fromJson(jsonDecode(profileJson));
      } else {
        // Create new profile with data from registration
        if (userDetails != null) {
          profile.name = userDetails['name'] ?? '';
          profile.email = userDetails['email'] ?? '';
        }
      }

      // Update preferences
      profile.preferences = _preferences;

      // Sync specific fields to main profile for easy access
      profile.experience = _preferences.experienceLevel;
      // You could also sync interests here if you want them to match categories or priorities
      // profile.interests = _preferences.jobCategories;

      profile.onboardingCompleted = true;

      // Save
      await prefs.setString(profileKey, jsonEncode(profile.toJson()));
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Progress 0.2 ... 1.0
    double progress = (_currentPage + 1) / _totalPages;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _prevPage,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  OnboardingStep1Experience(
                    selectedExperience: _preferences.experienceLevel.isEmpty
                        ? null
                        : _preferences.experienceLevel,
                    onSelect: (val) =>
                        setState(() => _preferences.experienceLevel = val),
                  ),
                  OnboardingStep2Categories(
                    selectedCategories: _preferences.jobCategories,
                    onToggle: (val) {
                      setState(() {
                        if (_preferences.jobCategories.contains(val)) {
                          _preferences.jobCategories.remove(val);
                        } else {
                          _preferences.jobCategories.add(val);
                        }
                      });
                    },
                  ),
                  OnboardingStep3Urgency(
                    selectedUrgency: _preferences.jobUrgency.isEmpty
                        ? null
                        : _preferences.jobUrgency,
                    onSelect: (val) =>
                        setState(() => _preferences.jobUrgency = val),
                  ),
                  OnboardingStep4Salary(
                    salaryMin: _preferences.salaryMin,
                    salaryMax: _preferences.salaryMax,
                    onRangeChanged: (min, max) => setState(() {
                      _preferences.salaryMin = min;
                      _preferences.salaryMax = max;
                    }),
                  ),
                  OnboardingStep5Priorities(
                    selectedPriorities: _preferences.jobPriorities,
                    onToggle: (val) {
                      setState(() {
                        if (_preferences.jobPriorities.contains(val)) {
                          _preferences.jobPriorities.remove(val);
                        } else {
                          _preferences.jobPriorities.add(val);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isStepValid() ? _nextPage : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
