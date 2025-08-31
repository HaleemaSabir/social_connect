import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  Future<void> _createPost() async {
    final content = _contentController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if ((content.isEmpty && _selectedImage == null) || user == null) return;

    setState(() => isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("post_images")
            .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

        await ref.putFile(File(_selectedImage!.path));
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid,
        'userEmail': user.email,
        'content': content,
        'imageUrl': imageUrl ?? '',
        'likes': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );

      _contentController.clear();
      setState(() => _selectedImage = null);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Create Post"), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _selectedImage != null
                ? Stack(
              children: [
                Image.file(
                  File(_selectedImage!.path),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() => _selectedImage = null);
                    },
                  ),
                ),
              ],
            )
                : ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Add Image"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Post"),
            ),
          ],
        ),
      ),
    );
  }
}
