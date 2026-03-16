import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ApplicationStatus { sent, invited, rejected }

class UserJobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID (Firebase Auth UID or fallback to username)
  Future<String> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    // Fallback if not using Firebase Auth yet
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('current_user');
    return username ?? 'guest';
  }

  Future<DocumentReference> _getUserDoc() async {
    final userId = await _getUserId();
    return _firestore.collection('users').doc(userId);
  }

  // --- Applied Jobs ---
  Future<void> saveAppliedJob(String vacancyId, String employerId) async {
    final userId = await _getUserId();
    final docRef = _firestore.collection('users').doc(userId);
    await docRef.set({
      'applied_jobs': {vacancyId: ApplicationStatus.sent.index}
    }, SetOptions(merge: true));

    // Also push a global application document so the Employer can read it
    if (employerId.isNotEmpty) {
      await _firestore.collection('applications').add({
        'candidateId': userId,
        'employerId': employerId,
        'vacancyId': vacancyId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateApplicationStatus(
      String vacancyId, ApplicationStatus status) async {
    final docRef = await _getUserDoc();
    await docRef.set({
      'applied_jobs': {vacancyId: status.index}
    }, SetOptions(merge: true));
  }

  Future<Map<String, ApplicationStatus>> getAppliedJobsMap() async {
    final docRef = await _getUserDoc();
    final doc = await docRef.get();
    if (!doc.exists) return {};

    final data = doc.data() as Map<String, dynamic>?;
    final appliedJobs = data?['applied_jobs'] as Map<String, dynamic>?;
    if (appliedJobs == null) return {};

    return appliedJobs
        .map((k, v) => MapEntry(k, ApplicationStatus.values[v as int]));
  }

  Future<List<String>> getAppliedJobIds() async {
    final map = await getAppliedJobsMap();
    return map.keys.toList();
  }

  // --- Saved (Favorites) ---
  Future<void> toggleSavedJob(String vacancyId) async {
    final docRef = await _getUserDoc();
    final isSaved = await isJobSaved(vacancyId);
    if (isSaved) {
      await docRef.update({
        'saved_jobs': FieldValue.arrayRemove([vacancyId])
      });
    } else {
      await docRef.set({
        'saved_jobs': FieldValue.arrayUnion([vacancyId])
      }, SetOptions(merge: true));
    }
  }

  Future<List<String>> getSavedJobs() async {
    final docRef = await _getUserDoc();
    final doc = await docRef.get();
    if (!doc.exists) return [];

    final data = doc.data() as Map<String, dynamic>?;
    final savedJobs = data?['saved_jobs'] as List<dynamic>?;
    return savedJobs?.map((e) => e.toString()).toList() ?? [];
  }

  Future<bool> isJobSaved(String vacancyId) async {
    final saved = await getSavedJobs();
    return saved.contains(vacancyId);
  }

  // --- Viewed (History) ---
  Future<void> markJobViewed(String vacancyId) async {
    final docRef = await _getUserDoc();
    await docRef.set({
      'viewed_jobs': FieldValue.arrayUnion([vacancyId])
    }, SetOptions(merge: true));
  }

  Future<List<String>> getViewedJobs() async {
    final docRef = await _getUserDoc();
    final doc = await docRef.get();
    if (!doc.exists) return [];

    final data = doc.data() as Map<String, dynamic>?;
    final viewedJobs = data?['viewed_jobs'] as List<dynamic>?;
    return viewedJobs?.map((e) => e.toString()).toList() ?? [];
  }
}
