import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';

class SeeAllScreen extends StatelessWidget {
  const SeeAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF8FA3D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8FA3D9),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: Colors.black),
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text(
                "Please login first",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
                 stream: FirebaseFirestore.instance
     .collection('users')
    .doc(user.uid)
    .collection('birthdays')
    .orderBy('createdAt', descending: true)
    .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No birthdays added yet",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  );
                }

                final birthdays = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: birthdays.length,
                  itemBuilder: (context, index) {
                    final birthday = birthdays[index];
                    final data = birthday.data() as Map<String, dynamic>;

                    String name = data['name'] ?? 'Unknown';
                    String phone = data['phone'] ?? '';
                    Timestamp? dobTimestamp = data['dob'];
                    String? base64Image = data['imageBase64'];

                    // Calculate DOB and days left
                    String dobText = "DOB: N/A";
                    String daysLeftText = "N/A";

                    if (dobTimestamp != null) {
                      DateTime dob = dobTimestamp.toDate();
                      
                      // Format: DOB:17JAN,2004
                      String month = _getMonthName(dob.month);
                      dobText = "DOB:${dob.day}$month,${dob.year}";

                      // Calculate next birthday
                      DateTime now = DateTime.now();
                      DateTime nextBirthday = DateTime(now.year, dob.month, dob.day);
                      
                      if (nextBirthday.isBefore(now)) {
                        nextBirthday = DateTime(now.year + 1, dob.month, dob.day);
                      }

                      int daysLeft = nextBirthday.difference(now).inDays;
                      daysLeftText = "${daysLeft}DaysLeft";
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BirthdayListCard(
                        docId: birthday.id,
                        name: name,
                        dob: dobText,
                        daysLeft: daysLeftText,
                        base64Image: base64Image,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }
}
class BirthdayListCard extends StatelessWidget {
  final String docId;
  final String name, dob, daysLeft;
  final String? base64Image;

  const BirthdayListCard({
    super.key,
    required this.docId,
    required this.name,
    required this.dob,
    required this.daysLeft,
    this.base64Image,
  });

  void _deleteBirthday(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Birthday"),
        content: const Text("Are you sure you want to delete this birthday?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('birthdays')
    .doc(docId)
    .delete();

    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (base64Image != null && base64Image!.isNotEmpty) {
      imageBytes = base64Decode(base64Image!);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8FA3D9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
            child: imageBytes == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(dob),
                Text(daysLeft),
              ],
            ),
          ),

          /// 🗑 DELETE ICON
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteBirthday(context),
          ),
        ],
      ),
    );
  }
}

