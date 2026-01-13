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
                    String? templateId = data['selectedTemplateId']; // ✅ NEW

                    String dobText = "DOB: N/A";
                    String daysLeftText = "N/A";

                    if (dobTimestamp != null) {
                      DateTime dob = dobTimestamp.toDate();
                      String month = _getMonthName(dob.month);
                      dobText = "DOB:${dob.day}$month,${dob.year}";

                      DateTime now = DateTime.now();
                      DateTime nextBirthday =
                          DateTime(now.year, dob.month, dob.day);

                      if (nextBirthday.isBefore(now)) {
                        nextBirthday =
                            DateTime(now.year + 1, dob.month, dob.day);
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
                        templateId: templateId, // ✅ PASSING TEMPLATE ID
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
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[month - 1];
  }
}

// ✅ UPDATED BIRTHDAY LIST CARD WITH TEMPLATE INFO
class BirthdayListCard extends StatelessWidget {
  final String docId;
  final String name, dob, daysLeft;
  final String? base64Image;
  final String? templateId; // ✅ NEW PARAMETER

  const BirthdayListCard({
    super.key,
    required this.docId,
    required this.name,
    required this.dob,
    required this.daysLeft,
    this.base64Image,
    this.templateId,
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
    final user = FirebaseAuth.instance.currentUser;
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
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage:
                    imageBytes != null ? MemoryImage(imageBytes) : null,
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
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteBirthday(context),
              ),
            ],
          ),

          // ✅ TEMPLATE INFO SECTION
          if (templateId != null && user != null)
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('templates')
                  .doc(templateId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade700),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Template not found",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final templateData =
                    snapshot.data!.data() as Map<String, dynamic>;
                final templateName = templateData['name'] ?? 'Unknown';
                final templateText = templateData['text'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade700, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.message,
                              color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Template: $templateName",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        templateText.length > 100
                            ? '${templateText.substring(0, 100)}...'
                            : templateText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "No template selected",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}