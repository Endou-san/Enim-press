import 'package:enim_press/src/features/newsfeed/Pages/users_screen.dart';
import 'package:flutter/material.dart';
import '../../Profil/Visitor and Admin/Profil_Screen_V_A.dart';
import 'General_Screen_Admin.dart';


class HomeScreenAdmin extends StatefulWidget {
  @override
  _HomeScreenAdminState createState() => _HomeScreenAdminState();
}

class _HomeScreenAdminState extends State<HomeScreenAdmin> {


  @override
  Widget build(BuildContext context) {
    

          return DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text(
                  "ENIM PRESS",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                bottom: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: const Color.fromARGB(255, 226, 223, 223),
                  ),
                  isScrollable: true,
                  tabs: const [
                    Tab(
                      child: Text(
                        "General",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Utilisateurs",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Profil",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  const GeneralScreenAdmin(),
                  UsersScreen(),
                  const ProfileScreenVA(),
                ],
              ),
            ),
          );
        } 
      }