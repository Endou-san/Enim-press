import 'package:enim_press/src/features/authentication/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../newsfeed/Pages/home_screen_V_E.dart';
import '../newsfeed/Pages/home_screen_admin.dart';

class Auth extends StatelessWidget {
  const Auth({Key? key}) : super(key: key);

  Stream<DatabaseEvent> getUserDataStream(String uid) {
    Query reference = FirebaseDatabase.instance
        .reference()
        .child('users')
        .orderByChild('uid')
        .equalTo(uid)
        .limitToFirst(1);

    return reference.onValue;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          String uid = snapshot.data!.uid;
          return StreamBuilder<DatabaseEvent>(
            stream: getUserDataStream(uid),
            builder:
                (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasData) {
                Map<dynamic, dynamic>? userData =
                    snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

                String nestedKey = userData!.keys.first;
                String role = userData[nestedKey]?['role'] ?? '';

                if (role == 'admin') {
                  return HomeScreenAdmin();
                } else {
                  return HomeScreenEditeur();
                }
              }
              // Ajouter un widget par défaut ici
              return LoginPage(key: UniqueKey());
            },
          );
        }
        return LoginPage(key: UniqueKey());
      },
    );
  }
}
