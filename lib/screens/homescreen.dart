import 'package:flutter/material.dart';
import 'drawer_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import './services/notification_service.dart'; // ✅ IMPORT NOTIFICATION SERVICE

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _currentIndex = 0;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    
    // ✅ APP OPEN HONE PAR NOTIFICATIONS CHECK KARO
    _checkBirthdayNotifications();
  }

  /// ✅ CHECK BIRTHDAYS AND SCHEDULE NOTIFICATIONS
  Future<void> _checkBirthdayNotifications() async {
    try {
      await NotificationService.checkAndScheduleNotifications();
    } catch (e) {
      print("❌ Error checking notifications: $e");
    }
  }

  /// Calculate days left for upcoming birthday
  String calculateDaysLeft(Timestamp dobTimestamp) {
    if (dobTimestamp == null) return "N/A";
    DateTime dob = dobTimestamp.toDate();
    DateTime now = DateTime.now();
    DateTime nextBirthday = DateTime(now.year, dob.month, dob.day);
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, dob.month, dob.day);
    }
    int daysLeft = nextBirthday.difference(now).inDays;
    
    // ✅ SPECIAL MESSAGES FOR TODAY AND TOMORROW
    if (daysLeft == 0) return "TODAY! 🎉";
    if (daysLeft == 1) return "TOMORROW! 🎂";
    
    return "$daysLeft Days Left";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // ✅ MANUAL REFRESH BUTTON - Notifications dobara check karne ke liye
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _checkBirthdayNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Notifications updated ✓"),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage("assets/user.jpg"),
                ),
                const SizedBox(width: 10),

                /// USER NAME
                StreamBuilder<DocumentSnapshot>(
                  stream: user == null
                      ? null
                      : FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (user == null ||
                        snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData ||
                        !snapshot.data!.exists) {
                      return const Text("Hi 👋");
                    }

                    final data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final userName = data['name'] ?? "User";

                    return Text(
                      "Hi $userName,\nHere are Today's Updates",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// WISHMATE CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("WishMate App",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text("The birthday\nreminder"),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.cake, color: Colors.blue),
                        Text("WishMate",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// UPCOMING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Upcoming Birthdays",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/seeAll");
                  },
                  child: const Text("See All"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// BIRTHDAYS GRID
            Expanded(
              child: user == null
                  ? const Center(child: Text("No Data"))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .collection('birthdays')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return const Center(
                              child: Text("No Birthdays 🎂"));
                        }

                        return GridView.builder(
                          itemCount: docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.3,
                          ),
                          itemBuilder: (context, index) {
                            final data = docs[index];

                            return BirthdayCard(
                              docId: data.id,
                              name: data['name'],
                              days: calculateDaysLeft(data['dob']),
                              imageBase64: data['imageBase64'],
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF8FA3D9),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 1) {
              Navigator.pushNamed(context, "/addBirthday");
            } else if (index == 2) {
              Navigator.pushNamed(context, "/viewTemplates");
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_box), label: "Templates"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
        ),
      ),
    );
  }
}

class BirthdayCard extends StatelessWidget {
  final String docId;
  final String name;
  final String days;
  final String imageBase64;

  const BirthdayCard({
    super.key,
    required this.docId,
    required this.name,
    required this.days,
    required this.imageBase64,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ CHECK IF BIRTHDAY IS TODAY OR TOMORROW
    final isSpecial = days.contains("TODAY") || days.contains("TOMORROW");
    
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        // ✅ SPECIAL COLOR FOR TODAY/TOMORROW
        color: isSpecial ? const Color(0xFFFFD700) : const Color(0xFFCACACA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSpecial ? Colors.orange : Colors.black,
          width: isSpecial ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: MemoryImage(base64Decode(imageBase64)),
          ),
          const SizedBox(height: 6),
          Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            days,
            style: TextStyle(
              fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal,
              color: isSpecial ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}