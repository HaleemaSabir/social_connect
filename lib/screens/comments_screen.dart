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

  void postComment() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final text = _commentController.text.trim();

    if (text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'userId': uid,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _commentController.clear();
    }
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
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final comments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text(comment['text']),
                      subtitle: Text(comment['userId']),
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
                  icon: const Icon(Icons.send),
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
