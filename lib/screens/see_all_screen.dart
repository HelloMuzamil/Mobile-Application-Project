import 'package:flutter/material.dart';

class SeeAllScreen extends StatelessWidget {
  const SeeAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          BirthdayListCard(
            name: "Muzammil",
            dob: "DOB:17JAN,2004",
            daysLeft: "35DaysLeft",
            imagePath: "assets/user.jpg",
          ),
          SizedBox(height: 16),
          BirthdayListCard(
            name: "Farhan",
            dob: "DOB:18JAN,2003",
            daysLeft: "36DaysLeft",
            imagePath: "assets/user.jpg",
          ),
          SizedBox(height: 16),
          BirthdayListCard(
            name: "Ahmad",
            dob: "DOB:21JUN,2004",
            daysLeft: "65DaysLeft",
            imagePath: "assets/user.jpg",
          ),
          SizedBox(height: 16),
          BirthdayListCard(
            name: "Shahab",
            dob: "DOB:12JULY,2005",
            daysLeft: "78DaysLeft",
            imagePath: "assets/user.jpg",
          ),
        ],
      ),
    );
  }
}

class BirthdayListCard extends StatelessWidget {
  final String name, dob, daysLeft, imagePath;

  const BirthdayListCard({
    super.key,
    required this.name,
    required this.dob,
    required this.daysLeft,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
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
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dob,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                daysLeft,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}