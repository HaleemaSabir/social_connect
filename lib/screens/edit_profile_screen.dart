import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  File? _image;
  String? _imageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCurrentUserData();
  }

  Future<void> loadCurrentUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      nameController.text = doc['name'] ?? '';
      bioController.text = doc['bio'] ?? '';
      _imageUrl = doc['imageUrl'] ?? '';
      setState(() {});
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<String> uploadImage(File file) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    setState(() => isLoading = true);

    try {
      String imageUrl = _imageUrl ?? '';

      if (_image != null) {
        imageUrl = await uploadImage(_image!);
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text.trim(),
        'bio': bioController.text.trim(),
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = _image != null
        ? FileImage(_image!)
        : (_imageUrl != null && _imageUrl!.isNotEmpty
        ? NetworkImage(_imageUrl!)
        : const AssetImage('assets/default_avatar.png')) as ImageProvider;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageWidget,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: "Bio"),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
