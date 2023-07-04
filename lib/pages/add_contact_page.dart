import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:simple_agenda/utils/alert.dart';
import 'package:simple_agenda/utils/nav.dart';

class AddContactPage extends StatefulWidget {
  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              child: const Text('Select Photo'),
              onPressed: () {
                _pickImage();
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              child: const Text('Save Contact'),
              onPressed: () {
                _saveContact();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _saveContact() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final contactName = _nameController.text.trim();
      final contactEmail = _emailController.text.trim();
      final contactPhone = _phoneController.text.trim();

      String photoUrl = '';

      if (_selectedImage != null) {
        final imageName = '${DateTime.now()}.jpg';
        final Reference storageReference =
            _storage.ref().child('contacts/$imageName');
        final UploadTask uploadTask = storageReference.putFile(_selectedImage!);
        final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        photoUrl = await snapshot.ref.getDownloadURL();
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('contacts')
            .add({
          'name': contactName,
          'email': contactEmail,
          'phone': contactPhone,
          'photoUrl': photoUrl,
        });
        pop(context);
      } else {
        alert(context, "You need to choose a photo to save a contact");
      }
    }
  }
}
