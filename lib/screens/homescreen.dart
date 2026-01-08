import 'package:flutter/material.dart';
import 'drawer_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';



class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Header
          Row(
  children: [
    const CircleAvatar(
      radius: 20,
      backgroundImage: AssetImage("assets/user.jpg"),
    ),
    const SizedBox(width: 10),

    ///USER NAME FROM FIRESTORE (REALTIME)
    StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Hi ...");
        }

        final userName = snapshot.data!['name'];

        return Text(
          "Hi $userName,\nHere are Today's Updates",
          style: const TextStyle(fontWeight: FontWeight.w600),
        );
      },
    ),
  ],
),


            const SizedBox(height: 20),

            /// WishMate Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "WishMate App",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    child: Column(
                      children: const [
                        Icon(Icons.cake, color: Colors.blue),
                        Text(
                          "WishMate",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Upcoming Birthdays
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upcoming Birthdays",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/seeAll");
                  },
                  child: const Text("See All"),
                ),
              ],
            ),

            const SizedBox(height: 10),

         Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('birthdays')
        .where(
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .snapshots(),

    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = snapshot.data!.docs;
      final now = DateTime.now();

      // ✅ Upcoming only (next 30 days)
      final upcoming = docs.where((doc) {
        DateTime dob = (doc['dob'] as Timestamp).toDate();

        DateTime nextBirthday =
            DateTime(now.year, dob.month, dob.day);

        if (nextBirthday.isBefore(now)) {
          nextBirthday =
              DateTime(now.year + 1, dob.month, dob.day);
        }

        return nextBirthday.difference(now).inDays <= 30;
      }).toList();

      if (upcoming.isEmpty) {
        return const Center(
          child: Text("No Upcoming Birthdays 🎂"),
        );
      }

      return GridView.builder(
        itemCount: upcoming.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (context, index) {
          final data = upcoming[index];

          DateTime dob =
              (data['dob'] as Timestamp).toDate();

          DateTime nextBirthday =
              DateTime(now.year, dob.month, dob.day);

          if (nextBirthday.isBefore(now)) {
            nextBirthday =
                DateTime(now.year + 1, dob.month, dob.day);
          }

          int daysLeft =
              nextBirthday.difference(now).inDays;

          return BirthdayCard(
            name: data['name'],
            days: "$daysLeft Days Left",
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

      /// Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF8FA3D9),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        currentIndex: _currentIndex,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            Navigator.pushNamed(context, "/addBirthday");
          } else if (index == 2) {
            Navigator.pushNamed(context, "/viewTemplates");
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Add Birthday",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "View Templates",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "",
          ),
        ],
      ),
    );
  }
}
class BirthdayCard extends StatelessWidget {
  final String name;
  final String days;
  final String imageBase64;

  const BirthdayCard({
    super.key,
    required this.name,
    required this.days,
    required this.imageBase64,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFCACACA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 0.8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                MemoryImage(base64Decode(imageBase64)),
          ),

          const SizedBox(width: 10),

          /// ✅ FIX IS HERE
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  days,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
