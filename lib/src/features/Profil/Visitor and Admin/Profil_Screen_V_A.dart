import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import '../../authentication/pages/login_page.dart';

class ProfileScreenVA extends StatelessWidget {
  const ProfileScreenVA ({Key? key}) : super(key: key);

  Stream<DatabaseEvent> getUserDataStream(String uid) {
    Query reference = FirebaseDatabase.instance
        .reference()
        .child('users')
        .orderByChild('uid')
        .equalTo(uid)
        .limitToFirst(1);

    return reference.onValue;
  }

  // Fonction pour déconnecter l'utilisateur
  void signOutUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
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
          String name = userData[nestedKey]?['fullName'] ?? '';

          String email = user?.email ?? '';
          print('Name: $name');

          String tMenuDeconnecter = 'Se déconnecter';

          return Scaffold(
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          'lib/src/images/profil.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.black.withOpacity(0.1),
                        ),
                        child: Icon(LineAwesomeIcons.alternate_sign_out, color: Colors.yellow),
                      ),
                      title: Text(tMenuDeconnecter, style: Theme.of(context).textTheme.bodyText1),
                      trailing: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey.withOpacity(0.1),
                        ),
                        child: IconButton(
                          onPressed: () { 
                            signOutUser(context);
                          },
                          icon: const Icon(LineAwesomeIcons.angle_right),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
