import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    try {
      final userId = await _getUserId();

      // Use a unique document ID to prevent duplicate applications for the same user and vacancy
      final applicationId = '${userId}_$vacancyId';

      if (employerId.isNotEmpty) {
        await _firestore.collection('applications').doc(applicationId).set({
          'userId': userId,
          'employerId': employerId,
          'vacancyId': vacancyId,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Ignore permission errors silently for UI stability
    }
  }

  Future<void> updateApplicationStatus(String vacancyId, String status) async {
    try {
      final userId = await _getUserId();
      // In a real app, this should only be done by Employers. We do it here for demo/testing.
      final query = await _firestore
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .where('vacancyId', isEqualTo: vacancyId)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({'status': status});
      }
    } catch (e) {
      // Ignore errors silently for UI stability
    }
  }

  Future<Map<String, String>> getAppliedJobsStatusMap() async {
    try {
      final userId = await _getUserId();
      final querySnapshot = await _firestore
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, String> statusMap = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final vacancyId = data['vacancyId'] as String?;
        final status = data['status'] as String? ?? 'pending';
        if (vacancyId != null) {
          statusMap[vacancyId] = status;
        }
      }
      return statusMap;
    } catch (e) {
      return {};
    }
  }

  Future<List<String>> getAppliedJobIds() async {
    final map = await getAppliedJobsStatusMap();
    return map.keys.toList();
  }

  // --- Saved (Favorites) ---
  Future<void> toggleSavedJob(String vacancyId) async {
    try {
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
    } catch (e) {
      // Ignore errors silently
    }
  }

  Future<List<String>> getSavedJobs() async {
    try {
      final docRef = await _getUserDoc();
      final doc = await docRef.get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>?;
      final savedJobs = data?['saved_jobs'] as List<dynamic>?;
      return savedJobs?.map((e) => e.toString()).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> isJobSaved(String vacancyId) async {
    final saved = await getSavedJobs();
    return saved.contains(vacancyId);
  }

  // --- Viewed (History) ---
  Future<void> markJobViewed(String vacancyId) async {
    try {
      final docRef = await _getUserDoc();
      await docRef.set({
        'viewed_jobs': FieldValue.arrayUnion([vacancyId])
      }, SetOptions(merge: true));
    } catch (e) {
      // Ignore errors
    }
  }

  Future<List<String>> getViewedJobs() async {
    try {
      final docRef = await _getUserDoc();
      final doc = await docRef.get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>?;
      final viewedJobs = data?['viewed_jobs'] as List<dynamic>?;
      return viewedJobs?.map((e) => e.toString()).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  // --- Skipped Jobs ---
  Future<void> markJobSkipped(String vacancyId) async {
    try {
      final docRef = await _getUserDoc();
      await docRef.set({
        'skipped_jobs': FieldValue.arrayUnion([vacancyId])
      }, SetOptions(merge: true));
    } catch (e) {
      // Ignore errors
    }
  }

  Future<List<String>> getSkippedJobIds() async {
    try {
      final docRef = await _getUserDoc();
      final doc = await docRef.get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>?;
      final skippedJobs = data?['skipped_jobs'] as List<dynamic>?;
      return skippedJobs?.map((e) => e.toString()).toList() ?? [];
    } catch (e) {
      return [];
    }
  }
}
