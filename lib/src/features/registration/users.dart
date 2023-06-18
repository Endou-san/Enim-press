import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class User {
  final String fullName;
  final String email;
  final String password;
  final String uid;
  final String role;
  List<String> likedArticles;

  User({
    required this.fullName,
    required this.email,
    required this.password,
    required this.uid,
    required this.role,
    required this.likedArticles,
  });
}

final DatabaseReference usersRef =
    FirebaseDatabase.instance.ref().child('users');

// Add a user from the signup form
void addUser(String fullName, String email, String password, String uid,
    String role, List<String> likedArticles) {
  usersRef.push().set({
    'fullName': fullName,
    'email': email,
    'password': password,
    'uid': uid,
    'role': role,
    'likedArticles': likedArticles,
  });
}

// Read all users
Future<List<User>> getUsers() async {
  DatabaseEvent event = await usersRef.once();
  DataSnapshot dataSnapshot = event.snapshot;
  final data = dataSnapshot.value as Map<dynamic, dynamic>;

  List<User> users = [];
  data.forEach((key, value) {
    User user = User(
      fullName: value['fullName'],
      email: value['email'],
      password: value['password'],
      uid: value['uid'],
      role: value['role'],
      likedArticles: List<String>.from(data['likedArticles']),
    );
    users.add(user);
  });

  return users;
}

Future<List<User>> getVisitor() async {
  DatabaseEvent dataSnapshot = await usersRef.once();
  List<User> visitors = [];

  Map<dynamic, dynamic>? usersData =
      dataSnapshot.snapshot.value as Map<dynamic, dynamic>?;

  if (usersData != null) {
    usersData.forEach((key, userData) {
      if (userData['role'] == 'visitor') {
        User visitor = User(
          fullName: userData['fullName'],
          email: userData['email'],
          password: userData['password'],
          uid: userData['uid'],
          role: userData['role'],
          likedArticles: List<String>.from(userData['likedArticles']),
        );
        visitors.add(visitor);
      }
    });
  }

  return visitors;
}

Future<List<User>> getEditor() async {
  DatabaseEvent dataSnapshot = await usersRef.once();
  List<User> editors = [];

  Map<dynamic, dynamic>? usersData =
      dataSnapshot.snapshot.value as Map<dynamic, dynamic>?;

  if (usersData != null) {
    usersData.forEach((key, userData) {
      if (userData['role'] == 'editor') {
        User editor = User(
          fullName: userData['fullName'],
          email: userData['email'],
          password: userData['password'],
          uid: userData['uid'],
          role: userData['role'],
          likedArticles: List<String>.from(userData['likedArticles']),
        );
        editors.add(editor);
      }
    });
  }

  return editors;
}

Future<void> updateUserRole(String email, String newRole) async {
  Query query = usersRef.orderByChild('email').equalTo(email);
  DatabaseEvent dataSnapshot = await query.once();

  Map<dynamic, dynamic>? userData =
      dataSnapshot.snapshot.value as Map<dynamic, dynamic>?;
  String documentKey = userData!.keys.first!;

  await usersRef.child(documentKey).update({
    'role': newRole,
  });
}

// Read a single user by UID
Future<User?> getUserByUID(String uid) async {
  DatabaseEvent event = await usersRef.once();
  DataSnapshot dataSnapshot = event.snapshot;
  final data = dataSnapshot.value as Map<dynamic, dynamic>;

  User? user;
  data.forEach((key, value) {
    if (value['uid'] == uid) {
      user = User(
        fullName: value['fullName'],
        email: value['email'],
        password: value['password'],
        uid: value['uid'],
        role: value['role'],
        likedArticles: value['likedArticles'],
      );
    }
  });

  return user;
}

// Update a user by UID
Future<void> updateUserByUID(String uid, String fullName, String email,
    String password, String role) async {
  DatabaseEvent event = await usersRef.once();
  DataSnapshot dataSnapshot = event.snapshot;
  final data = dataSnapshot.value as Map<dynamic, dynamic>;

  String? userKey;
  data.forEach((key, value) {
    if (value['uid'] == uid) {
      userKey = key;
    }
  });

  if (userKey != null) {
    await usersRef.child(userKey!).update({
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
    });
  }
}

// Delete a user by UID
Future<void> deleteUserByUID(String uid) async {
  DatabaseEvent event = await usersRef.once();
  DataSnapshot dataSnapshot = event.snapshot;
  final data = dataSnapshot.value as Map<dynamic, dynamic>;

  String? userKey;
  data.forEach((key, value) {
    if (value['uid'] == uid) {
      userKey = key;
    }
  });

  if (userKey != null) {
    await usersRef.child(userKey!).remove();
  }
}
