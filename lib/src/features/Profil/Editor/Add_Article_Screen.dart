import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../newsfeed/view_model/Article_firebase.dart';
import '../../newsfeed/view_model/image_Upload.dart';
class AddArticleScreen extends StatefulWidget {
  @override
  _AddArticleScreenState createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  String _imageUrl = '';

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
          String author = userData[nestedKey]?['fullName'] ?? '';
          _authorController.text = author;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Ajouter Article'),
            ),
            body: Column(
              children: [
                TextFormField(
                  controller: _authorController,
                  enabled: false,
                  decoration: const InputDecoration(
                    hintText: 'Auteur',
                  ),
                ),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Titre',
                  ),
                ),
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _contentController.text.isNotEmpty ? _contentController.text : 'Scolaire',
                  items: const [
                    DropdownMenuItem(value: 'Scolaire', child: Text('Scolaire')),
                    DropdownMenuItem(value: 'Parascolaire', child: Text('Parascolaire')),
                  ],
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      _contentController.text = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Genre Article',
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    await selectAndUploadImageToFirebase();

                    setState(() {
                      _imageUrl = downloadURL!;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _imageUrl.isNotEmpty ? 'Image Selected' : 'No Image Selected',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    String titre = _titleController.text;
                    String auteur = _authorController.text;
                    String description = _descriptionController.text;
                    String tags = _contentController.text;
                    String image = _imageUrl;
                    addArticle(titre, auteur, tags, description, image);
                    Navigator.pop(context);
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ajouter Article'),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
