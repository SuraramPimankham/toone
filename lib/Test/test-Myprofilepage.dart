import 'package:apptoon/Pages/menuProfile/AddFriendPage.dart';
import 'package:apptoon/Pages/menuProfile/MyCartoonsPage.dart';
import 'package:apptoon/Pages/menuProfile/AddCoinsPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:apptoon/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apptoon/screen/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfilePage extends StatefulWidget {
  final String? email;

  MyProfilePage({this.email});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // ล้างข้อมูลการลงชื่อเข้าใช้
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('email');

    // เมื่อคลิกที่ไอคอน "ออกจากระบบ" ให้นำทางไปยังหน้า Login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // จำนวนแท็บที่คุณต้องการ
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                signOut(context);
              },
            ),
          ],
          flexibleSpace: Container(
            alignment: Alignment.center,
            child: Container(
              width: 60,
              height: 60,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'images/logo1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'เติมเงิน'),
              Tab(text: 'การตูนร์ของฉัน'),
              Tab(text: 'เพื่อน'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AddCoinsPage(),
            AddFriendPage(),
            MyCartoonsPage(),
          ],
        ),
      ),
    );
  }
}
