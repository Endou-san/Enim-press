// ignore_for_file: unnecessary_import

// ignore: avoid_web_libraries_in_flutter

import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ArticleDetailsScreen extends StatefulWidget {
  final String? title,
      urlToImage,
      author,
      publishedAt,
      description,
      content,
      url;

  ArticleDetailsScreen({
    Key? key,
    this.title,
    this.urlToImage,
    this.author,
    this.publishedAt,
    this.description,
    this.content,
    this.url,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ArticleDetailsScreenState createState() => _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends State<ArticleDetailsScreen> {
  late File _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
    _imageFile = (pickedFile != null ? File(pickedFile.path) : null)!;


    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // ignore: unnecessary_null_comparison
            if (_imageFile != null)
              Image.file(_imageFile)
            else
              const Placeholder(fallbackHeight: 200),
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton(
                onPressed: _pickImage,
                child: const Icon(Icons.add_a_photo),
              ),), // fixed wrong closing parenthesis placement
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 340.0, 0.0, 0.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 3,
                width: MediaQuery.of(context).size.width,
                child: Material(
                  borderRadius: BorderRadius.circular(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                        child: Text(
                          widget.title!,
                          style: const TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        label: Text(
                          widget.publishedAt!.substring(0, 10),
                          style: const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                          widget.description!,
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                          widget.content!,
                          style: const TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Chip(
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          label: Text(
                            "Author : ${widget.author!}",
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.all(16),
                        elevation: 20,
                        color: Colors.black12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            InkWell(
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    Colors.black12.withOpacity(0.3),
                                    BlendMode.srcOver),
                                child: Image.network(
                                  widget.urlToImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              onTap: () async {
                                await launchUrlString(widget.url!);
                              },
                            ),
                            const Text(
                              "News Source",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ], // added missing closing bracket for children list
        ),
      ),
    );
  }
}


