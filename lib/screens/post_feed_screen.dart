import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostFeedScreen extends StatelessWidget {
  const PostFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Feed"), backgroundColor: Colors.teal),
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
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  title: Text(email),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(content),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(post.id)
                                  .update({'likes': likes + 1});
                            },
                          ),
                          Text(likes.toString()),
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
