import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multitask_lab/screens/cards.view.dart';
import 'package:multitask_lab/screens/home.view.dart';
import 'package:multitask_lab/screens/login.view.dart';
import 'package:multitask_lab/screens/profile.view.dart';

class Homepage extends StatefulWidget {

  Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();

  Future<String?> _getProfileImageUrl(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['profileImageUrl'];
  }
}

class _HomepageState extends State<Homepage> {
  int currentIndex = 0;

  List<Widget> pages = [HomeView(), LoginPage(), Cardsview(), Profilview()];
  void changePage(int mok) {
    setState(() {
      currentIndex = mok;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Multitask Application",
          style: Theme.of(context).textTheme.displayLarge,
          ),
      backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blueGrey,
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.login), label: "Login"),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Cards"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ], onTap: changePage,)
    );
  }
}