import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserProfile({
    required String name,
    required String bio,
    required String imageUrl,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'bio': bio,
      'imageUrl': imageUrl,
      'uid': uid,
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getUserById(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }
}
