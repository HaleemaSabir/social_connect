import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:social_connect/screens/comments_screen.dart';

class PostFeedScreen extends StatelessWidget {
  const PostFeedScreen({super.key});

  // ⚠️ Replace with your Firebase Console → Cloud Messaging → Server key
  static const String serverKey = "YOUR_FCM_SERVER_KEY";

  Future<void> sendPushMessage(String token, String title, String body) async {
    try {
      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "key=$serverKey",
        },
        body: jsonEncode({
          "to": token,
          "notification": {"title": title, "body": body},
        }),
      );
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  Future<void> handleLike(DocumentSnapshot post) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final postRef =
    FirebaseFirestore.instance.collection('posts').doc(post.id);

    // increment likes
    await postRef.update({'likes': (post['likes'] ?? 0) + 1});

    // send notification to post owner
    final ownerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(post['userId'])
        .get();

    if (ownerDoc.exists &&
        ownerDoc['fcmToken'] != null &&
        ownerDoc['fcmToken'] != '') {
      final token = ownerDoc['fcmToken'];
      await sendPushMessage(
        token,
        "New Like ❤️",
        "${currentUser.email} liked your post!",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Post Feed"), backgroundColor: Colors.teal),
      backgroundColor: Colors.teal[50],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading posts"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return const Center(child: Text("No posts yet."));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final content = post['content'] ?? '';
              final email = post['userEmail'] ?? 'Unknown';
              final likes = post['likes'] ?? 0;

              return Card(
                margin:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(content),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up),
                            onPressed: () => handleLike(post),
                          ),
                          Text(likes.toString()),

                          const SizedBox(width: 16),

                          // 🟢 Comment button
                          IconButton(
                            icon: const Icon(Icons.comment),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CommentsScreen(postId: post.id),
                                ),
                              );
                            },
                          ),
                          const Text("Comments"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
