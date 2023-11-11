import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apptoon/Pages/detailpage.dart';

class MyHomePage extends StatefulWidget {
  // Change to StatefulWidget
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Create the State class

  bool isActionCategoryVisible = false;
  bool isFantasyCategoryVisible = false;
  final ScrollController _scrollController = ScrollController();

  GlobalKey _buildActionKey = GlobalKey();
  GlobalKey _buildFantasyKey = GlobalKey();
  GlobalKey _buildComedyKey = GlobalKey();
  GlobalKey _buildRomanceKey = GlobalKey();
  GlobalKey _buildHorrorKey = GlobalKey();

// เรียกค่า rating จาก firebase
  Future<int> fetchRatingEP(String storyId) async {
    try {
      final storyRef =
          FirebaseFirestore.instance.collection("storys").doc(storyId);

      final document = await storyRef.get();
      if (document.exists) {
        final rating = document.data()?['rating'] as int;
        return rating ?? 0;
      }
      return 0; // คืนค่าเริ่มต้นถ้าเอกสารไม่มีหรือไม่มีข้อมูลคะแนน
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงคะแนนจาก Firestore: $e');
      return 0; // จัดการข้อผิดพลาดและคืนค่าเริ่มต้น
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Homepage'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildCategoryButtons(context),
            _buildRecommendedStories(context),
            _buildAction(context),
            _buildFantasy(context),
            _buildComedy(context),
            _buildRomance(context),
            _buildHorror(context),
          ],
        ),
      ),
    );
  }

//  หมดหมู่
  Widget _buildCategoryButtons(BuildContext context) {
    return Container(
      width: 400,
      color: Color.fromARGB(255, 241, 129, 166),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'หมวดหมู่',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _scrollController.position.ensureVisible(
                      _buildActionKey.currentContext!.findRenderObject()!,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                    );
                    print('Action');
                  },
                  child: Text('แอ็กชัน'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _scrollController.position.ensureVisible(
                      _buildFantasyKey.currentContext!.findRenderObject()!,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                    );
                    print('แฟนตาซี');
                  },
                  child: Text('แฟนตาซี'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _scrollController.position.ensureVisible(
                      _buildComedyKey.currentContext!.findRenderObject()!,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                    );
                    print('ตลก');
                  },
                  child: Text('ตลก'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _scrollController.position.ensureVisible(
                      _buildRomanceKey.currentContext!.findRenderObject()!,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                    );
                    print('โรแมนติก');
                  },
                  child: Text('โรแมนติก'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _scrollController.position.ensureVisible(
                      _buildHorrorKey.currentContext!.findRenderObject()!,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                    );
                    print('สยองขวัญ');
                  },
                  child: Text('สยองขวัญ'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//  แนะนำ
  Widget _buildRecommendedStories(BuildContext context) {
    return Container(
      width: 400,
      height: 338,
      color: Color.fromARGB(255, 241, 129, 166),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'แนะนำ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Container(
            height: 250,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('storys').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error.toString()}'),
                  );
                }
                final documents = snapshot.data?.docs;
                if (documents == null || documents.isEmpty) {
                  return Center(
                    child: Text('ไม่พบข้อมูลในคอลเลกชัน "storys"'),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final data = document.data() as Map<String, dynamic>;

                    final id = data['id'];
                    final author = data['author'];
                    final title = data['title'];
                    final imageUrl = data['imageUrl'];
                    final description = data['description'];

                    final itemWidth = 150.0;
                    final itemHeight = 250.0;

                    return GestureDetector(
                      onTap: () {
                        print(description);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              id: id,
                              author: author,
                              title: title,
                              imageUrl: imageUrl,
                              description: description,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: itemWidth,
                        height: itemHeight,
                        child: Card(
                          elevation: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// _buildAction
  Widget _buildAction(BuildContext context) {
    return Container(
      key: _buildActionKey,
      width: 400,
      height: 338,
      color: Color.fromARGB(255, 241, 129, 166),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'แอ็กชัน',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Container(
            height: 230,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('storys')
                  .where('categories', arrayContains: 'action')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error.toString()}'),
                  );
                }
                final documents = snapshot.data?.docs;
                if (documents == null || documents.isEmpty) {
                  return Center(
                    child: Text('ไม่พบข้อมูลในคอลเลกชัน "storys"'),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final data = document.data() as Map<String, dynamic>;

                    final id = data['id'];
                    final author = data['author'];
                    final title = data['title'];
                    final imageUrl = data['imageUrl'];
                    final description = data['description'];

                    return FutureBuilder<int>(
                        future: fetchRatingEP(id), // ดึงคะแนนจาก Firestore
                        builder: (context, ratingSanpshot) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    id: id,
                                    author: author,
                                    title: title,
                                    imageUrl: imageUrl,
                                    description: description,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              height: 120,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 150,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                imageUrl,
                                                width: 130,
                                                height: 150,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Text(
                                                '$title',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.favorite),
                                              Text(
                                                (ratingSanpshot.data ?? 0)
                                                    .toString(), // แสดงคะแนนจาก Firestore
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // _buildFantasy
  Widget _buildFantasy(BuildContext context) {
    return Container(
      key: _buildFantasyKey,
      width: 400,
      height: 338,
      color: Color.fromARGB(255, 241, 129, 166),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'แฟนตาซี',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Container(
            height: 230,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('storys')
                  .where('categories', arrayContains: 'fantasy')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error.toString()}'),
                  );
                }
                final documents = snapshot.data?.docs;
                if (documents == null || documents.isEmpty) {
                  return Center(
                    child: Text('ไม่พบข้อมูลในคอลเลกชัน "storys"'),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final data = document.data() as Map<String, dynamic>;

                    final id = data['id'];
                    final author = data['author'];
                    final title = data['title'];
                    final imageUrl = data['imageUrl'];
                    final description = data['description'];

                    return FutureBuilder<int>(
                        future: fetchRatingEP(id), // ดึงคะแนนจาก Firestore
                        builder: (context, ratingSnapshot) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    id: id,
                                    author: author,
                                    title: title,
                                    imageUrl: imageUrl,
                                    description: description,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              height: 120,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 150,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                imageUrl,
                                                width: 130,
                                                height: 150,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Text(
                                                '$title',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.remove_red_eye),
                                              Text(
                                                (ratingSnapshot.data ?? 0)
                                                    .toString(), // แสดงคะแนนจาก Firestore
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //  _buildComedy
  Widget _buildComedy(BuildContext context) {
    return Container(
      key: _buildComedyKey,
      width: 400,
      height: 338,
      color: Color.fromARGB(255, 241, 129, 166),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ตลก',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Container(
            height: 230,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('storys')
                  .where('categories', arrayContains: 'comedy')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error.toString()}'),
                  );
                }
                final documents = snapshot.data?.docs;
                if (documents == null || documents.isEmpty) {
                  return Center(
                    child: Text('ไม่พบข้อมูลในคอลเลกชัน "storys"'),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final data = document.data() as Map<String, dynamic>;

                    final id = data['id'];
                    final author = data['author'];
                    final title = data['title'];
                    final imageUrl = data['imageUrl'];
                    final description = data['description'];

                    return FutureBuilder<int>(
                        future: fetchRatingEP(id), // ดึงคะแนนจาก Firestore
                        builder: (context, ratingSnapshot) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    id: id,
                                    author: author,
                                    title: title,
                                    imageUrl: imageUrl,
                                    description: description,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              height: 120,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 150,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                imageUrl,
                                                width: 130,
                                                height: 150,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Text(
                                                '$title',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.remove_red_eye),
                                              Text(
                                                (ratingSnapshot.data ?? 0)
                                                    .toString(), // แสดงคะแนนจาก Firestore
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //  _buildRomance
  Widget _buildRomance(BuildContext context) {
    return Container(
      key: _buildRomanceKey,
      width: 400,
      height: 338,
      color: Color.fromARGB(255, 241, 129, 166),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'โรแมนติก',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Container(
            height: 230,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('storys')
                  .where('categories', arrayContains: 'romance')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error.toString()}'),
                  );
                }
                final documents = snapshot.data?.docs;
                if (documents == null || documents.isEmpty) {
                  return Center(
                    child: Text('ไม่พบข้อมูลในคอลเลกชัน "storys"'),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final data = document.data() as Map<String, dynamic>;

                    final id = data['id'];
                    final author = data['author'];
                    final title = data['title'];
                    final imageUrl = data['imageUrl'];
                    final description = data['description'];

                    return FutureBuilder<int>(
                        future: fetchRatingEP(id), // ดึงคะแนนจาก Firestore
                        builder: (context, ratingSnapshot) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    id: id,
                                    author: author,
                                    title: title,
                                    imageUrl: imageUrl,
                                    description: description,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              height: 120,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 150,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                imageUrl,
                                                width: 130,
                                                height: 150,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Text(
                                                '$title',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.remove_red_eye),
                                              Text(
                                                (ratingSnapshot.data ?? 0)
                                                    .toString(), // แสดงคะแนนจาก Firestore
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //  _buildRomance
  Widget _buildHorror(BuildContext context) {
    return Container(
      key: _buildHorrorKey,
      width: 400,
      height: 338,
      color: Color.fromARGB(255, 241, 129, 166),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'สยองขวัญ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Container(
            height: 230,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('storys')
                  .where('categories', arrayContains: 'horror')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error.toString()}'),
                  );
                }
                final documents = snapshot.data?.docs;
                if (documents == null || documents.isEmpty) {
                  return Center(
                    child: Text('ไม่พบข้อมูลในคอลเลกชัน "storys"'),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final data = document.data() as Map<String, dynamic>;

                    final id = data['id'];
                    final author = data['author'];
                    final title = data['title'];
                    final imageUrl = data['imageUrl'];
                    final description = data['description'];

                    return FutureBuilder<int>(
                        future: fetchRatingEP(id), // ดึงคะแนนจาก Firestore
                        builder: (context, ratingSnapshot) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    id: id,
                                    author: author,
                                    title: title,
                                    imageUrl: imageUrl,
                                    description: description,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              height: 120,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 150,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                imageUrl,
                                                width: 130,
                                                height: 150,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Text(
                                                '$title',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.remove_red_eye),
                                              Text(
                                                (ratingSnapshot.data ?? 0)
                                                    .toString(), // แสดงคะแนนจาก Firestore
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
