import 'package:shared_preferences/shared_preferences.dart';

class UserJobService {
  // Get current username to use as key prefix
  Future<String?> _getUsername() async {
    // We need the username (id), checking isLoggedIn doesn't give us the ID easily unless we store it.
    // AuthService stores 'current_user' as the username.
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user');
  }

  Future<void> saveAppliedJob(String vacancyId) async {
    final username = await _getUsername();
    if (username == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'applied_jobs_$username';

    final applied = prefs.getStringList(key) ?? [];
    if (!applied.contains(vacancyId)) {
      applied.add(vacancyId);
      await prefs.setStringList(key, applied);
    }
  }

  Future<List<String>> getAppliedJobIds() async {
    final username = await _getUsername();
    if (username == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final key = 'applied_jobs_$username';
    return prefs.getStringList(key) ?? [];
  }
}
