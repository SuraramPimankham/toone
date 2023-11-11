// import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apptoon/Pages/episode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apptoon/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailPage extends StatefulWidget {
  final String id;
  final String title;
  final String author;
  final String description;
  final String imageUrl;

  DetailPage({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.imageUrl,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite = false;
  User? _user; // ทำให้ _user เป็น nullable
  late List<String> episodes = [];
  late List<String> episodeIds = [];
  String selectedEpisodeId = '';
  // bool isPressed = false;
  // int count = 0;

  @override
  void initState() {
    super.initState();
    // ตรวจสอบสถานะการล็อกอินของผู้ใช้
    _user = FirebaseAuth.instance.currentUser;
    fetchEpisodes();
  }

  Stream<bool> checkFavoriteStory() {
    // สร้างและคืนค่า Stream จาก Firestore ที่ติดตาม user_favorite ของเอกสารนี้
    return FirebaseFirestore.instance
        .collection("storys")
        .doc(widget.id)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final userFavorite = snapshot.data()?['user_favorite'] as List;
        final userUid = FirebaseAuth.instance.currentUser?.uid;
        return userUid != null && userFavorite.contains(userUid);
      }
      return false; // ถ้าไม่มีเอกสารหรือไม่มีฟิล "user_favorite"
    });
  }

  Future<void> updateRatingStoryAndUser(bool isFavorite) async {
    try {
      final uid_user = _user?.uid;

      // อ้างอิงไปยังเอกสารใน Firestore
      final storyRef =
          FirebaseFirestore.instance.collection("storys").doc(widget.id);

      final document = await storyRef.get();

      if (document.exists) {
        // ตรวจสอบว่าฟิล "user_favorite" มีอยู่ในเอกสารหรือไม่
        final userFavoriteExists =
            document.data()!.containsKey('user_favorite');

        // ตรวจสอบว่า UID ของผู้ใช้อยู่ในฟิล "user_favorite" หรือไม่
        final userFavorite = userFavoriteExists
            ? (document.data()!['user_favorite'] as List)
            : [];

        if (uid_user != null) {
          if (userFavorite.contains(uid_user)) {
            // UID ของผู้ใช้อยู่ใน "user_favorite", ดังนั้นลดคะแนน (-1) และลบ UID ออกจาก "user_favorite"
            await storyRef.update({
              'rating': FieldValue.increment(-1),
              'user_favorite': FieldValue.arrayRemove([uid_user])
            });

            // Update the user document in the "users" collection
            await FirebaseFirestore.instance
                .collection("users")
                .doc(uid_user)
                .update({
              'favorite': FieldValue.arrayRemove([widget.id])
            });

            // เช็คหมวดหมู่ของเรื่อง
            final categories = document.data()!['categories'];

            if (categories != null) {
              for (final category in categories) {
                final categoryField = 'score_$category';
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid_user)
                    .update({categoryField: FieldValue.increment(-1)});
              }
            }
          } else {
            // UID ของผู้ใช้ไม่อยู่ใน "user_favorite", ดังนั้นเพิ่มคะแนน (+1) และเพิ่ม UID เข้าไปใน "user_favorite"
            await storyRef.update({
              'rating': FieldValue.increment(1),
              'user_favorite': FieldValue.arrayUnion([uid_user])
            });

            // Update the user document in the "users" collection
            await FirebaseFirestore.instance
                .collection("users")
                .doc(uid_user)
                .update({
              'favorite': FieldValue.arrayUnion([widget.id])
            });

            // เช็คหมวดหมู่เรื่อง
            final categories = document.data()!['categories'];

            if (categories != null) {
              for (final category in categories) {
                final categoryField = 'score_$category';
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid_user)
                    .update({categoryField: FieldValue.increment(1)});
              }
            }
          }
        }
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการอัปเดต rating และ favorite ใน Firestore: $e');
    }
  }

  Future<int> getRatingStory() async {
    try {
      final storyRef =
          FirebaseFirestore.instance.collection("storys").doc(widget.id);

      final document = await storyRef.get();
      if (document.exists) {
        final rating = document.data()?['rating'] as int;
        return rating ?? 0;
      }
      return 0; // ถ้าไม่มีเอกสารหรือไม่มีฟิล "rating"
    } catch (e) {
      print('Error fetching rating from Firestore: $e');
      return 0; // ในกรณีที่เกิดข้อผิดพลาด
    }
  }

  Stream<int> fetchRatingEP(String episodeId) {
    final episodeRef =
        FirebaseFirestore.instance.collection(widget.id).doc(episodeId);

    return episodeRef.snapshots().map((document) {
      if (document.exists) {
        final rating = document.data()?['rating'];
        if (rating is int) {
          return rating;
        } else {
          return 0; // ถ้า rating ไม่ใช่ int ให้คืนค่าเริ่มต้น 0
        }
      } else {
        return 0; // ค่าคะแนนเริ่มต้นถ้าไม่พบข้อมูล
      }
    }).handleError((error) {
      print('เกิดข้อผิดพลาดในการดึงคะแนนจาก Firestore: $error');
      return 0; // จัดการข้อผิดพลาดโดยการให้ค่าเริ่มต้น 0
    });
  }

  // ต้องแก้
  Future<void> checkUserLoginStatus(bool isLocked, String episodeId) async {
    // ตรวจสอบว่าผู้ใช้ล็อกอินอยู่หรือไม่
    bool isLoggedIn = _user != null;

    if (isLoggedIn) {
      // มีการเข้าสู่ระบบ ให้ไปยังหน้า EpisodePage
      goToEpisodePage(episodeId);
    } else if (!isLoggedIn && !isLocked) {
      goToEpisodePage(episodeId);
    } else {
      // ถ้าตอนนี้มีการล็อค
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MyProfile(),
        ),
      );
    }
  }

  void goToEpisodePage(String episodeId) {
    // นำทางไปยังหน้า EpisodePage โดยใช้ episodeId
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EpisodePage(
          toonId: widget.id,
          episodeId: episodeId,
          episodes: episodes,
        ),
      ),
    );
  }

  Future<void> fetchEpisodes() async {
    try {
      CollectionReference episodesCollection =
          FirebaseFirestore.instance.collection(widget.id);

      QuerySnapshot episodesSnapshot = await episodesCollection.get();

      if (episodesSnapshot.docs.isNotEmpty) {
        setState(() {
          episodes.clear();
          episodeIds.clear();
        });

        episodesSnapshot.docs.forEach((doc) {
          String episode_id = doc.id;
          String episode = doc['ep'];
          episodes.add('EP $episode');
          episodeIds.add(episode_id);
        });

        episodes.sort((a, b) {
          int aEpisodeNumber = int.parse(a.split(' ')[1]);
          int bEpisodeNumber = int.parse(b.split(' ')[1]);
          return bEpisodeNumber.compareTo(aEpisodeNumber);
        });
        episodeIds.sort((a, b) {
          int aEpisodeNumber = int.tryParse(a.split('EP ')[1]) ?? 0;
          int bEpisodeNumber = int.tryParse(b.split('EP ')[1]) ?? 0;
          return bEpisodeNumber.compareTo(aEpisodeNumber);
        });
      }
    } catch (e) {
      print('Error fetching episodes: $e');
    }
  }

  Future<void> updatePurchasedEpisodes(
      String uid, String toonId, String title, String episodeId) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      await userRef.update({
        'purchasedEpisodes': FieldValue.arrayUnion([
          {
            'toonId': toonId,
            'title': title,
            'episodeId': episodeId,
          }
        ])
      });
    } catch (e) {
      print('Error updating purchased episodes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('รายละเอียดเรื่อง'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(5),
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Color.fromARGB(255, 235, 177, 196),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(2),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.imageUrl,
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(''),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Title: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(''),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Author: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.author,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: StreamBuilder<bool>(
                                    stream:
                                        checkFavoriteStory(), // สร้างฟังก์ชันนี้เพื่อรับ Stream ในการติดตามการกด Favorite
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Icon(
                                          Icons.favorite_border,
                                          color: Colors.white,
                                          size: 24,
                                        );
                                      } else {
                                        final isUserFavorite =
                                            snapshot.data ?? false;
                                        return Icon(
                                          isUserFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.white,
                                          size: 24,
                                        );
                                      }
                                    },
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isFavorite = !isFavorite;
                                    });

                                    updateRatingStoryAndUser(isFavorite);
                                  },
                                ),
                                FutureBuilder<int>(
                                  future: getRatingStory(),
                                  builder: (context, snapshot) {
                                    return Text(
                                      '${snapshot.data ?? 0}',
                                      style: TextStyle(fontSize: 16),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Colors.black,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: episodes.asMap().entries.map((entry) {
                    int episodeNumber =
                        int.tryParse(episodes[entry.key].split(' ')[1]) ?? 0;

                    // เช็คว่า EP มีการติด Icon Lock หรือไม่
                    bool isLocked = episodeNumber >= 4;

                    return Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: Color.fromARGB(255, 235, 177, 196),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () async {
                          if (_user == null && !isLocked) {
                            // ถ้าผู้ใช้ไม่ได้เข้าสู่ระบบ และตอนไม่ได้ lock ให้ไปยังหน้า
                            String episode_id = episodeIds[entry.key];
                            setState(() {
                              selectedEpisodeId = episode_id;
                            });
                            goToEpisodePage(episode_id);
                          } else if (_user == null) {
                            // ถ้าผู้ใช้ไม่ได้เข้าสู่ระบบ ให้ไปยังหน้า MyProfile
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MyProfile(),
                              ),
                            );
                          } else {
                            // ถ้าผู้ใช้เข้าสู่ระบบ
                            String episode_id = episodeIds[entry.key];
                            setState(() {
                              selectedEpisodeId = episode_id;
                            });

                            // สร้าง bool check data coiiection users ที่ doc == uid ให้ค้นหา field purchasedEpisodes ซึ่งเก็บ เป็น array โดยใน array เก็บเป็น map ใน เก็บ 3 field
                            if (true) {}

                            if (isLocked) {
                              // ดึงข้อมูล coin จาก Firestore
                              DocumentSnapshot userDoc = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .doc(_user?.uid)
                                  .get();

                              // ตรวจสอบว่ามีเหรียญพอหรือไม่
                              int coins = userDoc['coin'] ?? 0;

                              if (coins >= 15) {
                                // แสดงตัวเลือกการซื้อ
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('EP ที่ติด Icon Lock'),
                                      content:
                                          Text("ต้องการซื้อ EP นี้หรือไม่?"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('ยกเลิก'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('ซื้อ'),
                                          onPressed: () async {
                                            // ลบเหรียญ 15 จาก Firestore
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(_user?.uid ??
                                                    '') // ใช้ null-aware operator ที่นี่
                                                .update({
                                              'coin': FieldValue.increment(-15),
                                            });

                                            // ทำการอัปเดตฟิลด์ purchasedEpisodes ใน Firestore
                                            await updatePurchasedEpisodes(
                                                _user?.uid ?? '',
                                                widget.id,
                                                widget.title,
                                                episode_id);

                                            // ทำการนำทางไปยังหน้า EpisodePage
                                            Navigator.of(context).pop();
                                            goToEpisodePage(episode_id);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                // แจ้งเตือนถ้าเงินไม่พอ
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('เงินไม่พอ'),
                                      content: Text(
                                          "คุณไม่มีเหรียญเพียงพอที่จะซื้อ EP นี้"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('ตกลง'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } else {
                              // EP ไม่ติด Icon Lock ให้ไปยังหน้า EpisodePage โดยตรง
                              goToEpisodePage(episode_id);
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection(widget.id)
                                  .doc(episodeIds[entry.key])
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // แสดง CircularProgressIndicator ในระหว่างโหลดข้อมูล
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 8,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    const Color.fromARGB(
                                                        255, 255, 255, 255)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  if (snapshot.hasError) {
                                    // ถ้าเกิดข้อผิดพลาดในการโหลดข้อมูล
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // ถ้าโหลดข้อมูลสำเร็จ
                                    List<dynamic> imagesDynamic =
                                        snapshot.data?['images'] ?? [];
                                    List<String> images = imagesDynamic
                                        .map((e) => e.toString())
                                        .cast<String>()
                                        .toList();
                                    String imageUrl = images.isNotEmpty
                                        ? images[0]
                                        : ''; // ดึง URL ภาพแรกจาก images

                                    if (imageUrl.isNotEmpty) {
                                      // ถ้ามี URL ให้แสดงรูปภาพ
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: 70,
                                            height: 70,
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      // ถ้าไม่มี URL ให้ใช้ Container ว่าง
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: 70,
                                            height: 70,
                                            child: Container(),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                            Column(
                              children: [
                                Text(
                                  'Ep ${episodes[entry.key].split(' ')[1]}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.favorite, color: Colors.white),
                                    //  แสดง data
                                    StreamBuilder<int>(
                                      stream:
                                          fetchRatingEP(episodeIds[entry.key]),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'เกิดข้อผิดพลาด: ${snapshot.error}');
                                        } else {
                                          final rating = snapshot.data;
                                          final displayRating =
                                              (rating != null) ? rating : 0;
                                          return Text('$displayRating');
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            if (isLocked)
                              Text('15', style: TextStyle(fontSize: 16)),
                            if (isLocked)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(Icons.monetization_on_outlined,
                                    color: Colors.black),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
