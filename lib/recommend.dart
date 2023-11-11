import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Recommend extends StatefulWidget {
  const Recommend({Key? key}) : super(key: key);

  @override
  State<Recommend> createState() => _RecommendState();
}

class _RecommendState extends State<Recommend> {
  // สร้างอ้างอิงไปยัง Firebase Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Future<void> createCollection() async {
    try {
      await _firestore.collection('Recommend').add({
        'action': 'storys',
        'comedy': 'storys',
        'fantasy': 'storys',
        'horror': 'storys',
        'romance': 'storys',
        // เพิ่มฟิลด์อื่นๆ ตามที่คุณต้องการ
      });
      print('สร้างคอลเลกชันเรียบร้อย');
    } catch (e) {
      print('เกิดข้อผิดพลาดในการสร้างคอลเลกชัน: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
