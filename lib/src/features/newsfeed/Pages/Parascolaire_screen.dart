import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../view_model/Article_firebase.dart';

class ParaScolarScreen extends StatelessWidget {
  const ParaScolarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Article>>(
        future: getArticleParacolar(context),
        builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                Article article = snapshot.data![index];

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
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 20, 10, 20),
                                  child: Text(
                                    article.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
