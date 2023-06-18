import 'package:enim_press/src/features/registration/users.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
  List<User> editors = [];
  List<User> visitors = [];



  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchEditors();
    fetchVisitors();
  }

  Future<void> fetchEditors() async {
    List<User> fetchedEditors = await getEditor();
    setState(() {
      editors = fetchedEditors;
    });
  }

  Future<void> fetchVisitors() async {
    List<User> fetchedVisitors = await getVisitor();
    setState(() {
      visitors = fetchedVisitors;
    });
  }
@override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 2,
    child: Column(
      children: [
        TabBar(
          indicatorColor: Colors.lightBlue[800],
          unselectedLabelColor: Colors.grey[600],
          labelColor: Colors.black,
          tabs: [
            Tab(text: 'Visiteurs'),
            Tab(text: 'Editeurs'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              ListView.builder(
                itemCount: visitors.length,
                itemBuilder: (context, index) {
                  User visitor = visitors[index];
                  return ListTile(
                    title: Text(visitor.fullName),
                    subtitle: Text(visitor.email),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        setState(() {
                          User newEditor = User(
                            fullName: visitor.fullName,
                            email: visitor.email,
                            password: visitor.password,
                            uid: visitor.uid,
                            role: 'editor',
                            likedArticles: visitor.likedArticles,
                          );
                          visitors.remove(visitor);
                          editors.add(newEditor);
                          updateUserRole(visitor.email, 'editor');
                        });
                      },
                    ),
                  );
                },
              ),
              ListView.builder(
                itemCount: editors.length,
                itemBuilder: (context, index) {
                  User editor = editors[index];
                  return ListTile(
                    title: Text(editor.fullName),
                    subtitle: Text(editor.email),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        setState(() {
                          User newVisitor = User(
                            fullName: editor.fullName,
                            email: editor.email,
                            password: editor.password,
                            uid: editor.uid,
                            role: 'visitor',
                            likedArticles: editor.likedArticles,
                          );
                          editors.remove(editor);
                          visitors.add(newVisitor);
                          updateUserRole(editor.email, 'visitor');
                        });
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}