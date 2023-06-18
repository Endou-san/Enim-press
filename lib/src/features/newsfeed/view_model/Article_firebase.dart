import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/src/widgets/framework.dart';

class Article {
  final String authorId;
  late final String title;
  final String tags;
  late final String description;
  final String createdDate;
  final String image;
  int likes;

  Article({
    required this.authorId,
    required this.title,
    required this.tags,
    required this.description,
    required this.createdDate,
    required this.image,
    required this.likes,
  });
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
        authorId: map['authorId'],
        title: map['title'],
        tags: map['tags'],
        description: map['description'],
        createdDate: map['createdDate'],
        image: map['image'],
        likes: map['likes']);
  }

  get date => null;
}

final DatabaseReference articlesRef =
    FirebaseDatabase.instance.ref().child('Articles');

Future<void> likeArticle(String title) async {
  User? user = FirebaseAuth.instance.currentUser;
  String uid = user?.uid ?? '';

  if (user != null) {
    DatabaseReference usersRef =
        FirebaseDatabase.instance.reference().child('users');

    Query query = usersRef.orderByChild('uid').equalTo(uid);
    DatabaseEvent dataSnapshot = await query.once();
    Map<dynamic, dynamic>? userData =
        dataSnapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (userData != null) {
      String documentKey =
          userData.keys.first!; // Récupérer la clé du document existant
      print('documentKey: $documentKey');
      List<String> likedArticles =
          List<String>.from(userData[documentKey]['likedArticles'] ?? []);

      if (!likedArticles.contains(title)) {
        likedArticles.add(title);

        Query titleQuery = articlesRef.orderByChild('title').equalTo(title);
        DatabaseEvent articleSnapshot = await titleQuery.once();
        Map<dynamic, dynamic>? articleData =
            articleSnapshot.snapshot.value as Map<dynamic, dynamic>?;

        if (articleData != null) {
          String articleKey = articleData
              .keys.first!; // Récupérer la clé du document de l'article
          int currentLikes = articleData[articleKey]['likes'];
          await articlesRef.child(articleKey).update({
            'likes': currentLikes + 1,
          });
        }

        await usersRef.child(documentKey).update({
          'likedArticles': likedArticles,
        });
      } else {
        print('likedArticles');
      }
    }
  }
}

// Create a new article
void addArticle(String title, String author, String tags, String description,
    String image) {
  articlesRef.push().set({
    'title': title,
    'authorId': author,
    'tags': tags,
    'description': description,
    'image': image,
    'createdDate': DateTime.now().toIso8601String(),
    'likes': 0,
  });
}

Future<List<Article>> getArticles(BuildContext context) async {
  DatabaseEvent event = await articlesRef.once();
  DataSnapshot dataSnapshot = event.snapshot;
  final data = dataSnapshot.value as Map<dynamic, dynamic>;

  List<Article> articles = [];
  data.forEach((key, value) {
    Article article = Article(
        title: value['title'],
        authorId: value['authorId'],
        tags: value['tags'],
        description: value['description'],
        createdDate: value['createdDate'],
        image: value['image'],
        likes: value['likes']);

    articles.add(article);
  });

  return articles;
}

Future<List<Article>> getArticleScolar(BuildContext context) async {
  List<Article> articles = await getArticles(context);

  List<Article> articlesAvecTagScolaire =
      articles.where((article) => article.tags.contains('Scolaire')).toList();

  return articlesAvecTagScolaire;
}

Future<List<Article>> getArticleParacolar(BuildContext context) async {
  List<Article> articles = await getArticles(context);

  List<Article> articlesAvecTagScolaire = articles
      .where((article) => article.tags.contains('Parascolaire'))
      .toList();

  return articlesAvecTagScolaire;
}

Future<List<String>> getArticleIds(BuildContext context) async {
  DatabaseEvent event = await articlesRef.once();
  DataSnapshot dataSnapshot = event.snapshot;
  final data = dataSnapshot.value as Map<dynamic, dynamic>;

  List<String> articleIds = data.keys.cast<String>().toList();

  return articleIds;
}

Future<void> updateArticle(String createdDate, String authorId, String title,
    String description) async {
  DatabaseEvent event = await articlesRef.once();
  DataSnapshot dataSnapshot = event.snapshot;
  final articlesData = dataSnapshot.value as Map<dynamic, dynamic>;

  articlesData.forEach((key, value) async {
    Map<dynamic, dynamic> articleData = value;
    String articleCreatedDate = articleData['createdDate'];
    String articleAuthorId = articleData['authorId'];

    if (articleCreatedDate == createdDate && articleAuthorId == authorId) {
      await articlesRef.child(key).update({
        'title': title,
        'description': description,
      });
    }
  });
}

// Read a single article
Future<Article?> getArticle(String articleId) async {
  DatabaseEvent event = await articlesRef.child(articleId).once();
  DataSnapshot dataSnapshot = event.snapshot;
  final data = dataSnapshot.value as Map<dynamic, dynamic>;

  Article article = Article(
      authorId: data['authorId'],
      createdDate: data['createdDate'],
      description: data['description'],
      image: data['image'],
      tags: data['tags'],
      title: data['title'],
      likes: data['likes']);

  return article;
}

Future<void> deleteArticle(String createdDate, String authorId) async {
  DatabaseEvent event = await articlesRef.once();
  DataSnapshot dataSnapshot = event.snapshot;
  final articlesData = dataSnapshot.value as Map<dynamic, dynamic>;

  articlesData.forEach((key, value) async {
    Map<dynamic, dynamic> articleData = value;
    String articleCreatedDate = articleData['createdDate'];
    String articleAuthorId = articleData['authorId'];

    if (articleCreatedDate == createdDate && articleAuthorId == authorId) {
      await articlesRef.child(key).remove();
    }
  });
}