import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_connect/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // if null, show current user
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authService = AuthService();
  String name = "";
  String bio = "";
  String imageUrl = "";
  List followers = [];
  List following = [];

  bool isCurrentUser = true;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  void fetchProfile() async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final uid = widget.userId ?? currentUid;
    setState(() {
      isCurrentUser = uid == currentUid;
    });

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() {
        name = doc['name'] ?? '';
        bio = doc['bio'] ?? '';
        imageUrl = doc['imageUrl'] ?? '';
        followers = doc['followers'] ?? [];
        following = doc['following'] ?? [];
        isFollowing = followers.contains(currentUid);
      });
    }
  }

  Future<void> toggleFollow() async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final targetUid = widget.userId;

    if (targetUid == null) return;

    final targetRef = FirebaseFirestore.instance.collection('users').doc(targetUid);
    final currentRef = FirebaseFirestore.instance.collection('users').doc(currentUid);

    if (isFollowing) {
      // Unfollow
      await targetRef.update({
        'followers': FieldValue.arrayRemove([currentUid])
      });
      await currentRef.update({
        'following': FieldValue.arrayRemove([targetUid])
      });
    } else {
      // Follow
      await targetRef.update({
        'followers': FieldValue.arrayUnion([currentUid])
      });
      await currentRef.update({
        'following': FieldValue.arrayUnion([targetUid])
      });
    }

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  void logout() async {
    await authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? "My Profile" : "$name's Profile"),
        backgroundColor: Colors.teal,
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: logout,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(bio, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text("Followers: ${followers.length}  •  Following: ${following.length}"),
            const SizedBox(height: 24),

            if (isCurrentUser)
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(50),
                ),
              )
            else
              ElevatedButton(
                onPressed: toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? Colors.grey : Colors.teal,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(isFollowing ? "Unfollow" : "Follow"),
              ),
          ],
        ),
      ),
    );
  }
}
