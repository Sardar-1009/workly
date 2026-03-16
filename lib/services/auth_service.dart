import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register a new user
  Future<String?> register(
      String name, String email, String username, String password) async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Save additional user data in Firestore
        await _firestore.collection('users').doc(user.uid).set(
            {
              'name': name,
              'email': email,
              'username': username,
              'createdAt': FieldValue.serverTimestamp(),
            },
            SetOptions(
                merge:
                    true)); // Merge in case of existing empty applied_jobs doc
        return null; // Success, no error message
      }
      return 'Failed to create user.';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists for that email.';
      }
      return e.message ?? 'Registration failed.';
    } catch (e) {
      return e.toString();
    }
  }

  // Login user
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success, no error message
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-credential') {
        return 'Invalid email or password.';
      }
      return e.message ?? 'Login failed.';
    } catch (e) {
      return e.toString();
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // Get current user details from Firestore
  Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // Get current user name helper
  Future<String?> getCurrentUserName() async {
    final details = await getCurrentUserDetails();
    return details?['name'];
  }
}
