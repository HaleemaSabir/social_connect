import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login
  Future<UserCredential?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save FCM token after login
      await _saveUserToken(result.user!);

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign Up + Create Firestore Profile
  Future<void> signupAndCreateProfile(String name, String email, String password) async {
    try {
      final trimmedEmail = email.trim();

      // Check if email already exists
      final existingMethods = await _auth.fetchSignInMethodsForEmail(trimmedEmail);
      if (existingMethods.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'This email is already in use.',
        );
      }

      // Create Firebase user
      final result = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password.trim(),
      );

      // Save user info to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'name': name.trim(),
        'email': trimmedEmail,
        'bio': '',
        'imageUrl': '',
        'fcmToken': '', // will be updated below
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save token right after signup
      await _saveUserToken(result.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Save FCM token to Firestore
  Future<void> _saveUserToken(User user) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      print("Error saving FCM token: $e");
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {
      throw 'Logout failed. Please try again.';
    }
  }

  // Handle FirebaseAuth exceptions
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}
