import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_agenda/pages/contact_list_page.dart';
import 'package:simple_agenda/utils/nav.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Agenda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              child: const Text('Sign Up'),
              onPressed: () {
                _signUp();
              },
            ),
            ElevatedButton(
              child: const Text('Log In'),
              onPressed: () {
                _login();
              },
            ),
            Text(
              _error,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _signUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(
          _nameController.text.trim(),
        );

        push(context, ContactListPage(), replace: true);

      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? '';
      });
    }
  }

  void _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        if (_nameController.text.isNotEmpty) {
          userCredential.user!.updateDisplayName(_nameController.text.trim());
        }

        push(context, ContactListPage(), replace: true);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? '';
      });
    }
  }
}
