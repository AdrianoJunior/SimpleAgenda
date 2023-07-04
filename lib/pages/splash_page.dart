import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_agenda/pages/auth_page.dart';
import 'package:simple_agenda/pages/contact_list_page.dart';
import 'package:simple_agenda/utils/nav.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3)).then((value) {
      if(FirebaseAuth.instance.currentUser != null) {
        push(context, ContactListPage(), replace: true);
      } else {
        push(context, AuthPage(), replace: true);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(child: Center(child: CircularProgressIndicator(),),);
  }
}
