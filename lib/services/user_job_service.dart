import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum ApplicationStatus { sent, invited, rejected }

class UserJobService {
  // Get current username to use as key prefix
  Future<String> _getPrefix() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('current_user');
    if (username == null) return 'guest_';
    return '${username}_';
  }

  // --- Applied Jobs ---

  // Stored as Map<String, int> where int is index of enum
  Future<void> saveAppliedJob(String vacancyId) async {
    final prefix = await _getPrefix();
    final prefs = await SharedPreferences.getInstance();
    final key = '${prefix}applied_jobs_map';

    // Load existing
    String? jsonString = prefs.getString(key);
    Map<String, dynamic> appliedMap =
        jsonString != null ? jsonDecode(jsonString) : {};

    // Add new (default status: sent = 0)
    appliedMap[vacancyId] = ApplicationStatus.sent.index;

    await prefs.setString(key, jsonEncode(appliedMap));
  }

  Future<void> updateApplicationStatus(
      String vacancyId, ApplicationStatus status) async {
    final prefix = await _getPrefix();
    final prefs = await SharedPreferences.getInstance();
    final key = '${prefix}applied_jobs_map';

    String? jsonString = prefs.getString(key);
    Map<String, dynamic> appliedMap =
        jsonString != null ? jsonDecode(jsonString) : {};

    if (appliedMap.containsKey(vacancyId)) {
      appliedMap[vacancyId] = status.index;
      await prefs.setString(key, jsonEncode(appliedMap));
    }
  }

  Future<Map<String, ApplicationStatus>> getAppliedJobsMap() async {
    final prefix = await _getPrefix();
    final prefs = await SharedPreferences.getInstance();
    final key = '${prefix}applied_jobs_map';

    String? jsonString = prefs.getString(key);
    if (jsonString == null) return {};

    Map<String, dynamic> rawMap = jsonDecode(jsonString);
    return rawMap
        .map((k, v) => MapEntry(k, ApplicationStatus.values[v as int]));
  }

  // --- Saved (Favorites) ---

  Future<void> toggleSavedJob(String vacancyId) async {
    final prefix = await _getPrefix();
    final prefs = await SharedPreferences.getInstance();
    final key = '${prefix}saved_jobs';

    List<String> saved = prefs.getStringList(key) ?? [];
    if (saved.contains(vacancyId)) {
      saved.remove(vacancyId);
    } else {
      saved.add(vacancyId);
    }
    await prefs.setStringList(key, saved);
  }

  Future<List<String>> getSavedJobs() async {
    final prefix = await _getPrefix();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('${prefix}saved_jobs') ?? [];
  }

  Future<bool> isJobSaved(String vacancyId) async {
    final saved = await getSavedJobs();
    return saved.contains(vacancyId);
  }

  // --- Viewed (History) ---

  Future<void> markJobViewed(String vacancyId) async {
    final prefix = await _getPrefix();
    final prefs = await SharedPreferences.getInstance();
    final key = '${prefix}viewed_jobs';

    List<String> viewed = prefs.getStringList(key) ?? [];
    if (!viewed.contains(vacancyId)) {
      viewed.add(vacancyId); // Add to end
      await prefs.setStringList(key, viewed);
    }
  }

  Future<List<String>> getViewedJobs() async {
    final prefix = await _getPrefix();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('${prefix}viewed_jobs') ?? [];
  }
}
