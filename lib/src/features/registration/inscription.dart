import 'package:enim_press/src/features/newsfeed/view_model/Article_firebase.dart';
import 'package:enim_press/src/features/registration/emailwhitelist.dart';
import 'package:enim_press/src/features/registration/users.dart';
import 'package:enim_press/src/features/registration/users.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../newsfeed/Pages/home_screen_V_E.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  //String _selectedRole = '';
  final DatabaseReference _userCollection =
      FirebaseDatabase.instance.reference().child('users');
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  
  

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String fullName = '';
    String Email = '';
    String password = '';
    String ConfirmP = '';
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Image.asset('lib/src/images/logo.png', height: 100.0, width: 100.0),
                Center(
                  child: Text(
                    'Créer votre compte chez ENIM PRESS',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom Complet',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? 'Entrez votre Nom Complet' : null,
                  onChanged: (val) => fullName = val,
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email institutionnel',
                    border: OutlineInputBorder(),
                  ),
                  // validator: (val) => val!.isEmpty ? 'Entrez votre email' : null,
                  // onChanged: (val) => Email = val,
                  
                  validator: (val) {
                      if (val!.isEmpty) {
                        return 'Entrez votre email';
                      }
                      if (!val.endsWith('@enim.ac.ma')) {
                        return 'Format de l\'Email invalide';
                      }
                      return null;
                    },
                  onChanged: (val) {
                      setState(() {
                        var errorMessage = '';
                        Email = val;
                      });
                    },
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.length < 6 ? 'Entrez un mot de passe avec 6 caractères minimum' : null,
                  onChanged: (val) => password = val,
                  obscureText: true,
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Confirmez le mot de passe',
                    border: OutlineInputBorder()  
                   ),
                  onChanged: (val) => ConfirmP = val,
                  validator: (val) => ConfirmP != password ? 'Mot de passe ne correspond pas! Réessayez!' :null,
                  obscureText: true,
                 ),
                
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String nom = _fullNameController.text;
                      String email = _emailController.text;
                      String password = _passwordController.text;
                    
                      // Créer un compte utilisateur avec authentification Firebase
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(email: email, password: password)
                          .then((userCredential) async {
                        // L'inscription s'est bien passée, vous pouvez ajouter l'utilisateur à votre base de données en temps réel Firebase
                        String uid = userCredential.user!.uid;
                        String role='visitor';
                        List<String> likedArticles = ['article1', 'article2', 'article3'];
                 
                         List<String> whitelist = await getEmailWhitelist();
                         bool emailInWhitelist = checkEmailInWhitelist(email,whitelist) as bool;
                           if (emailInWhitelist) {
                             role = 'editor';
                           } else {
                             role = 'visitor';
                           }
                        
                       
                 

                        addUser(nom, email, password, uid, role, likedArticles);

                        // Naviguer vers l'écran suivant après l'inscription
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreenEditeur()),
                        );
                      }).catchError((error) {
                        // Une erreur s'est produite lors de la création du compte utilisateur
                        print("Erreur d'inscription : $error");
                      });
                    }
                  },
                  child: const Text('S\'inscrire'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
