import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'src/features/authentication/Auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCeeD59m4ETARmFKCVEWVz7X5_7qzzD1HQ",
      appId: "1:549517049446:android:4dca40231a41b2cfbff7a7",
      messagingSenderId: "549517049446",
      projectId: "enim-press",
      databaseURL: "https://enim-press-default-rtdb.firebaseio.com",
      storageBucket: "enim-press.appspot.com",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Auth(),
    );
  }
}