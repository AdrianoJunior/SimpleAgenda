import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_agenda/pages/auth_page.dart';
import 'package:simple_agenda/pages/contact_details_page.dart';
import 'package:simple_agenda/pages/add_contact_page.dart';
import 'package:simple_agenda/utils/nav.dart';

class ContactListPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      drawer: Drawer(
        child: FutureBuilder(
          future: _getCurrentUser(),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasData) {
              final currentUser = snapshot.data!;
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(currentUser.displayName ?? ''),
                    accountEmail: Text(currentUser.email ?? ''),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(currentUser.photoURL ??
                          'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      _auth.signOut();
                      Navigator.pop(context);
                      push(context, AuthPage(), replace: true);
                    },
                  ),
                ],
              );
            } else {
              return const ListTile(
                title: Text('User Not Found'),
              );
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _firestore
                    .collection('users')
                    .doc(_auth.currentUser!.uid)
                    .collection('contacts')
                    .orderBy('name')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No contacts found.'),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((document) {
                      final contactName = document['name'];
                      final contactPhotoUrl = document['photoUrl'];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(contactPhotoUrl),
                        ),
                        title: Text(contactName),
                        onTap: () {
                          push(context, ContactDetailsPage(document));
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddContactPage(),
            ),
          );
        },
      ),
    );
  }

  Future<User> _getCurrentUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      await _auth.signInAnonymously();
      currentUser = _auth.currentUser;
    }
    return currentUser!;
  }
}
