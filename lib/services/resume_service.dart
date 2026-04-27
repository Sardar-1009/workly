import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResumeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Сохраняет ссылку на резюме (Google Drive, Dropbox, HH.ru и т.д.) в Firestore.
  Future<void> saveResumeUrl(String url, {String? fileName}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');

    await _firestore.collection('users').doc(userId).update({
      'resumeUrl': url,
      'resumeFileName': fileName ?? _extractFileName(url),
      'resumeUploadedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Удаляет ссылку на резюме из Firestore.
  Future<void> deleteResume() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'resumeUrl': '',
      'resumeFileName': '',
      'resumeUploadedAt': FieldValue.delete(),
    });
  }

  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final last = segments.last;
        if (last.isNotEmpty && last.contains('.')) return last;
      }
    } catch (_) {}
    return 'Resume';
  }
}
