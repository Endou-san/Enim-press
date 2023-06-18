import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../registration/inscription.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
void resetPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    // Succès : l'e-mail de réinitialisation du mot de passe a été envoyé à l'utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Veuillez vérifier votre boîte mail.'),
      ),
    );
  } catch (error) {
    // Gérer les erreurs de réinitialisation du mot de passe
    print('Erreur lors de la réinitialisation du mot de passe : $error');
  }
}



  Future<void> signUserIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      String errorMessage = 'Adresse mail ou mot de passe incorect ';

      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          errorMessage = 'Aucun utilisateur trouvé avec cette adresse e-mail';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Mot de passe incorrect';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(errorMessage),
  ),
);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'lib/src/images/logo.png',
                  width: 120,
                  height: 100,
                ),
                const SizedBox(height: 50),
                Text(
                  'Bienvenue de nouveau à ENIM PRESS!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: usernameController,
                  hintText: 'Adresse mail',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Mot de passe',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Appeler la méthode de réinitialisation du mot de passe ici
                          resetPassword(usernameController.text);
                        },
                        child: Text(
                          'Mot de passe oublié?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                MyButton(
                  onTap: signUserIn,
                  child: const Text('Se connecter'),
                ),
                const SizedBox(height: 50),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Créer un nouveau compte',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: Text(
                        'S\'inscrire',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
