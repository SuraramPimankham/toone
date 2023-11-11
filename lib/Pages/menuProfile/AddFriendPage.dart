import 'package:flutter/material.dart';

class MyCartoonsPage extends StatefulWidget {
  const MyCartoonsPage({Key? key}) : super(key: key);

  @override
  State<MyCartoonsPage> createState() => _MyCartoonsPageState();
}

class _MyCartoonsPageState extends State<MyCartoonsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('เพื่อน'), // สามารถแทนด้วยเนื้อหาที่คุณต้องการแสดง
      ),
    );
  }
}
