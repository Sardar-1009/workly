import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service to handle uploading/deleting 15-second video introductions
/// to Firebase Storage and persisting the download URL in Firestore.
class VideoIntroService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Upload the recorded video bytes to Firebase Storage and save the URL in Firestore.
  /// [videoBytes] – the raw bytes of the recorded video file.
  /// [onProgress] – optional callback for upload progress (0.0 to 1.0).
  /// Returns the public download URL.
  Future<String> uploadIntroVideo(
    Uint8List videoBytes, {
    void Function(double progress)? onProgress,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Пользователь не авторизован');

    // On web, the camera plugin records in WebM format, not MP4
    final extension = kIsWeb ? 'webm' : 'mp4';
    final contentType = kIsWeb ? 'video/webm' : 'video/mp4';

    final ref = _storage.ref().child('users/$uid/intro_video.$extension');

    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
    );

    final task = ref.putData(videoBytes, metadata);

    // Listen for progress
    if (onProgress != null) {
      task.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      }, onError: (_) {});
    }

    // Wait for upload to complete with a timeout
    final snapshot = await task.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        task.cancel();
        throw Exception('Загрузка заняла слишком долго. Проверьте интернет-соединение.');
      },
    );

    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Persist URL in Firestore
    await _firestore.collection('users').doc(uid).update({
      'introVideoUrl': downloadUrl,
      'introVideoUploadedAt': FieldValue.serverTimestamp(),
    });

    return downloadUrl;
  }

  /// Upload from a File (mobile / non-web).
  Future<String> uploadIntroVideoFromFile(
    File file, {
    void Function(double progress)? onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    return uploadIntroVideo(bytes, onProgress: onProgress);
  }

  /// Delete the intro video from Storage and clear the URL in Firestore.
  Future<void> deleteIntroVideo() async {
    final uid = _uid;
    if (uid == null) return;

    // Try deleting both possible extensions
    for (final ext in ['mp4', 'webm']) {
      try {
        final ref = _storage.ref().child('users/$uid/intro_video.$ext');
        await ref.delete();
      } catch (_) {}
    }

    await _firestore.collection('users').doc(uid).update({
      'introVideoUrl': '',
      'introVideoUploadedAt': FieldValue.delete(),
    });
  }
}
