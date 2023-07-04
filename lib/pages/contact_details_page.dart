import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactDetailsPage extends StatelessWidget {
  final DocumentSnapshot contact;

  ContactDetailsPage(this.contact);

  @override
  Widget build(BuildContext context) {
    final contactName = contact['name'];
    final contactEmail = contact['email'];
    final contactPhotoUrl = contact['photoUrl'];

    return Scaffold(
      appBar: AppBar(
        title: Text(contactName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 64.0,
              backgroundImage: NetworkImage(contactPhotoUrl),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Name: $contactName',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Email: $contactEmail',
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
