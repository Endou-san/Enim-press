// ignore_for_file: use_key_in_widget_constructors

import 'package:enim_press/src/features/newsfeed/Pages/Parascolaire_screen.dart';
import 'package:enim_press/src/features/newsfeed/Pages/Scolar_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../Profil/Editor/Profil_screen_editor.dart';
import '../../Profil/Visitor and Admin/Profil_Screen_V_A.dart';
import 'general_screen.dart';

class HomeScreenEditeur extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenEditeurState createState() => _HomeScreenEditeurState();
}

class _HomeScreenEditeurState extends State<HomeScreenEditeur> {
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
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user?.uid ?? '';

    return StreamBuilder<DatabaseEvent>(
      stream: getUserDataStream(uid),
      builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Text('Utilisateur introuvable');
          }

          Map<dynamic, dynamic>? userData =
              snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

          if (userData == null) {
            return Text('Utilisateur introuvable');
          }

          String nestedKey = userData.keys.first;
          String role = userData[nestedKey]?['role'] ?? '';

          return DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text(
                  "ENIM PRESS",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                bottom: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: const Color.fromARGB(255, 226, 223, 223),
                  ),
                  isScrollable: true,
                  tabs: const [
                    Tab(
                      child: Text(
                        "General",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Scolaire",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Parascolaire",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Profil",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  GeneralScreen(),
                  ScolarScreen(),
                  ParaScolarScreen(),
                  if (role == 'editor') ...[
                    ProfileScreenEditor(),
                  ] else ...[
                    ProfileScreenVA(),
                  ],
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
