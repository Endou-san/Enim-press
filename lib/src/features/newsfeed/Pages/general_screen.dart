import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view_model/Article_firebase.dart';

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({Key? key}) : super(key: key);

  @override
  _GeneralScreenState createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  late List<String> likedArticles; // Liste des articles aimés par l'utilisateur

  @override
  void initState() {
    super.initState();
    loadLikedArticles(); // Charge les articles aimés par l'utilisateur lors de l'initialisation du widget
  }

  Future<List<String>> getLikedArticles() async {
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user?.uid ?? '';

    DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');
    Query userQuery = usersRef.orderByChild('uid').equalTo(uid).limitToFirst(1);
    DatabaseEvent event = await userQuery.once();
    DataSnapshot dataSnapshot = event.snapshot;
    Map<dynamic, dynamic>? userData = dataSnapshot.value as Map<dynamic, dynamic>?;

    if (userData != null) {
      String nestedKey = userData.keys.first;
      List<String> likedArticles = List<String>.from(userData[nestedKey]?['likedArticles'] ?? []);
      return likedArticles;
    }

    return []; // Retourne une liste vide si les données de l'utilisateur n'ont pas été trouvées
  }

  Future<void> loadLikedArticles() async {
    likedArticles = await getLikedArticles(); // Appelle la méthode pour obtenir les articles aimés
    setState(() {}); // Met à jour l'état du widget pour afficher les articles aimés
  }

  Future<void> saveLikedArticles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('likedArticles', likedArticles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Article>>(
        future: getArticles(context), // Utilisez articleFirebase.getArticles pour appeler la méthode depuis ArticleFirebase
        builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Erreur lors du chargement des articles.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                Article article = snapshot.data![index];

                bool isLiked = likedArticles.contains(article.title);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return Scaffold(
                            appBar: AppBar(
                              title: Text(article.title),
                            ),
                            body: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'By ${article.authorId} on ${article.createdDate}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Image.network(
                                      article.image,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      article.description,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35.0),
                          child: Image.network(
                            article.image,
                            fit: BoxFit.cover,
                            height: 400.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 350.0, 0.0, 0),
                        child: SizedBox(
                          height: 200.0,
                          width: 750.0,
                          child: Material(
                            borderRadius: BorderRadius.circular(35.0),
                            elevation: 10.0,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (likedArticles.contains(article.title)) {
                                        likedArticles.remove(article.title);
                                        article.likes++;
                                        
                                      } else {
                                        likedArticles.add(article.title);
                                        likeArticle(article.title);
                                      }
                                      isLiked = likedArticles.contains(article.title);
                                    });
                                  
                                  },
                                  icon: Icon(
                                    Icons.favorite,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        article.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
