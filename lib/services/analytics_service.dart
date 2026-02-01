import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

enum AnalyticsEventType {
  view,
  swipe,
  apply,
  details, // "Read More"
}

class AnalyticsService {
  static const String _prefix = 'analytics_';

  String _getDateKey() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  // Log an event for today
  Future<void> logEvent(AnalyticsEventType type) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _getDateKey();
    final key = '${_prefix}${type.name}_$dateKey';

    final currentCount = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, currentCount + 1);
  }

  // Get stats for the current week (mock implementation: just gets TOTALS for MVP)
  // Real implementation would iterate 7 days.
  Future<Map<String, int>> getWeeklyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey =
        _getDateKey(); // For MVP we focus on "Today" or just accumulated counts

    // We will return accumulated counts for simple display,
    // but in a real app we'd sum up the last 7 days.

    int views = 0;
    int swipes = 0;
    int applies = 0;
    int details = 0;

    // A hacky way for MVP: Just showing "Today's" stats or accumulated stats if we don't clear them.
    // For a better graph, we'd need to fetch 7 keys.
    // Let's fetch counts for "today" for simplicity in MVP display.

    views = prefs.getInt('${_prefix}view_$dateKey') ?? 0;
    swipes = prefs.getInt('${_prefix}swipe_$dateKey') ?? 0;
    applies = prefs.getInt('${_prefix}apply_$dateKey') ?? 0;
    details = prefs.getInt('${_prefix}details_$dateKey') ?? 0;

    return {
      'views': views,
      'swipes': swipes,
      'applies': applies,
      'details': details,
    };
  }
}
