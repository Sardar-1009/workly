import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/user_profile.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../main_wrapper.dart';
import 'steps/onboarding_step_1_experience.dart';
import 'steps/onboarding_step_2_skills.dart';
import 'steps/onboarding_step_3_education.dart';
import 'steps/onboarding_step_4_about.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // Draft State
  String _experience = '';
  List<String> _skills = [];
  String _education = '';
  String _about = '';

  @override
  void initState() {
    super.initState();
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
      Navigator.of(context).pop();
    }
  }

  bool _isStepValid() {
    switch (_currentPage) {
      case 0: // Experience
        return _experience.isNotEmpty;
      case 1: // Skills
        return _skills.isNotEmpty;
      case 2: // Education
        return _education.isNotEmpty;
      case 3: // About
        return _about.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _finishOnboarding() async {
    final authService = AuthService();
    final userDetails = await authService.getCurrentUserDetails();
    final prefs = await SharedPreferences.getInstance();

    final authUser = FirebaseAuth.instance.currentUser;
    final currentUserId = authUser?.uid;

    if (currentUserId != null) {
      UserProfile profile = UserProfile();
      final profileKey = 'profile_$currentUserId';
      final profileJson = prefs.getString(profileKey);

      if (profileJson != null) {
        profile = UserProfile.fromJson(jsonDecode(profileJson));
      } else {
        if (userDetails != null) {
          profile.fullName = userDetails['fullName'] ?? '';
          profile.email = userDetails['email'] ?? '';
        }
      }

      // Update fields
      profile.experience = _experience;
      profile.skills = _skills;
      profile.education = _education;
      profile.about = _about;
      profile.onboardingCompleted = true;

      // Save locally
      await prefs.setString(profileKey, jsonEncode(profile.toJson()));
      
      // Save to Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(currentUserId).set({
          'skills': _skills,
          'experience': _experience,
          'education': _education,
          'about': _about,
          'onboardingCompleted': true,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error saving onboarding state to Firestore: $e");
      }
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    selectedExperience: _experience.isEmpty ? null : _experience,
                    onSelect: (val) => setState(() => _experience = val),
                  ),
                  OnboardingStep2Skills(
                    selectedSkills: _skills,
                    onToggle: (val) {
                      setState(() {
                        if (_skills.contains(val)) {
                          _skills.remove(val);
                        } else {
                          _skills.add(val);
                        }
                      });
                    },
                  ),
                  OnboardingStep3Education(
                    selectedEducation: _education.isEmpty ? null : _education,
                    onSelect: (val) => setState(() => _education = val),
                  ),
                  OnboardingStep4About(
                    aboutText: _about,
                    onChanged: (val) => setState(() => _about = val),
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
