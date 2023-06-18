import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../newsfeed/view_model/Article_firebase.dart';

class MyArticleScreen extends StatefulWidget {
  const MyArticleScreen({Key? key}) : super(key: key);

  @override
  _MyArticleScreenState createState() => _MyArticleScreenState();
}

class _MyArticleScreenState extends State<MyArticleScreen> {
  late List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    getArticles();
  }

  Future<void> getArticles() async {
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user?.uid ?? '';

    DatabaseReference articlesRef =
        FirebaseDatabase.instance.reference().child('Articles');
    Query articlesQuery = articlesRef.orderByChild('authorId');

    DatabaseReference usersRef =
        FirebaseDatabase.instance.reference().child('users');
    Query userQuery = usersRef.orderByChild('uid').equalTo(uid).limitToFirst(1);

    DatabaseEvent userDataEvent = await userQuery.once();
    DataSnapshot userDataSnapshot = userDataEvent.snapshot;
    Map<dynamic, dynamic>? userData =
        userDataSnapshot.value as Map<dynamic, dynamic>?;

    if (userData == null || userData.isEmpty) {
      return;
    }

    String nestedKey = userData.keys.first;
    String fullName = userData[nestedKey]?['fullName'];

    if (fullName == null) {
      return;
    }

    articlesQuery = articlesQuery.equalTo(fullName);

    DatabaseEvent articlesDataEvent = await articlesQuery.once();
    DataSnapshot articlesDataSnapshot = articlesDataEvent.snapshot;
    Map<dynamic, dynamic>? articlesData =
        articlesDataSnapshot.value as Map<dynamic, dynamic>?;

    if (articlesData != null) {
      List<Article> fetchedArticles = [];

      for (var key in articlesData.keys) {
        Map<dynamic, dynamic> articleData =
            articlesData[key] as Map<dynamic, dynamic>;
        articleData['id'] = key; // Add the 'id' field to the article map
        fetchedArticles
            .add(Article.fromMap(articleData.cast<String, dynamic>()));
      }

      setState(() {
        articles = fetchedArticles;
      });
    } else {
      print('No articles found in the database for the current user.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Articles'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (BuildContext context, int index) {
          Article article = articles[index];

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return ArticleDetailsScreen(
                      article: article,
                      onUpdate: (Article updatedArticle) {
                        setState(() {});
                      },
                    );
                  },
                ),
              );
            },
            child: ListTile(
              title: Text(article.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Par ${article.authorId} en ${article.createdDate}'),
                  Text('${article.likes} Likes'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ArticleDetailsScreen extends StatefulWidget {
  late final Article article;
  final Function(Article) onUpdate;

  ArticleDetailsScreen({
    required this.article,
    required this.onUpdate,
  });

  @override
  _ArticleDetailsScreenState createState() => _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends State<ArticleDetailsScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late Article updatedArticle;
  late String createdDate;
  late String author;

  void updateArticleDetails(Article updatedArticle) {
    setState(() {
      widget.article = updatedArticle;
      titleController.text = updatedArticle.title;
      descriptionController.text = updatedArticle.description;
    });
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.article.title);
    descriptionController =
        TextEditingController(text: widget.article.description);
    updatedArticle = widget.article;

    createdDate = widget.article.createdDate;
    author = widget.article.authorId;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.article.title),
        ),
        body: SingleChildScrollView(
          // Utiliser SingleChildScrollView pour permettre le défilement
          child: Container(
            padding: const EdgeInsets.all(16.0),
            alignment:
                Alignment.center, // Aligner le contenu au centre de l'écran
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Centrer verticalement les éléments
              children: [
                Text(
                  widget.article.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Par ${widget.article.authorId} le ${widget.article.createdDate}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(widget.article.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text('Vous voulez modifier cet article?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                String title = titleController.text;
                                String description = descriptionController.text;

                                updateArticle(
                                    widget.article.createdDate,
                                    widget.article.authorId,
                                    title,
                                    description);
                                widget.onUpdate(widget.article);
                                updateArticleDetails(widget.article);

                                Navigator.pop(context); // Close the dialog
                                Navigator.pop(
                                    context); // Close the article details screen
                              },
                              child: Text('Modifier'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(
                        255, 54, 82, 244), // Change the button color to red
                    onPrimary: Colors.white, // Change the text color to white
                  ),
                  icon: Icon(Icons.edit),
                  label: Text('Modifier'),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text('Vous voulez supprimer cet article?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteArticle(widget.article.createdDate,
                                    widget.article.authorId);
                                Navigator.pop(context); // Close the dialog
                                Navigator.pop(
                                    context); // Close the article details screen
                              },
                              child: Text('Supprimer'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Change the button color to red
                    onPrimary: Colors.white, // Change the text color to white
                  ),
                  icon: Icon(Icons.delete),
                  label: Text('Supprimer'),
                ),
              ],
            ),
          ),
        ));
  }
}
