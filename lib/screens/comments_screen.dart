import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_connect/widgets/custom_textfield.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> postComment() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final name = userDoc['name'] ?? currentUser.email;
    final imageUrl = userDoc['imageUrl'] ?? '';

    // Save comment
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'userId': currentUser.uid,
      'userName': name,
      'userImage': imageUrl,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Notify post owner
    final postDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get();

    if (postDoc.exists && postDoc['userId'] != currentUser.uid) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(postDoc['userId'])
          .collection('notifications')
          .add({
        'title': 'New Comment 💬',
        'body': '$name commented: $text',
        'timestamp': FieldValue.serverTimestamp(),
        'postId': widget.postId,
      });
    }

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: commentsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comments = snapshot.data!.docs;

                if (comments.isEmpty) {
                  return const Center(child: Text("No comments yet."));
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final name = comment['userName'] ?? 'Unknown';
                    final text = comment['text'] ?? '';
                    final imageUrl = comment['userImage'] ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
                      ),
                      title: Text(name),
                      subtitle: Text(text),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _commentController,
                    labelText: "Write a comment...",
                    prefixIcon: Icons.message,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: postComment,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
