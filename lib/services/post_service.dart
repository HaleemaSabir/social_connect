import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostService {
  final postsRef = FirebaseFirestore.instance.collection('posts');

  Future<void> createPost(String text, File? imageFile) async {
    String imageUrl = '';
    if (imageFile != null) {
      final ref = FirebaseStorage.instance
          .ref('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    await postsRef.add({
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  Stream<QuerySnapshot> getPostFeed() {
    return postsRef.orderBy('timestamp', descending: true).snapshots();
  }
}
