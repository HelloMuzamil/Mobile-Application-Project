import 'package:flutter/material.dart';

class ViewTemplatesScreen extends StatelessWidget {
  const ViewTemplatesScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Template List",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                children: const [
                  TemplateCard(
                    number: "1)",
                    text:
                        "Happy birthday to my best friend / and the person I can always count on for a good time.",
                  ),
                  SizedBox(height: 16),
                  TemplateCard(
                    number: "2)",
                    text:
                        "Wishing you a wonderful birthday / and a year filled with great professional achievements.",
                  ),
                  SizedBox(height: 16),
                  TemplateCard(
                    number: "3)",
                    text:
                        "Happy birthday on turning another year older / and still being way too immature for your age.",
                  ),
                  SizedBox(height: 16),
                  TemplateCard(
                    number: "4)",
                    text:
                        "Happy birthday on turning another year older / and still being way too immature for your age.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Add Template Button
           SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(context, "/addTemplate");
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3C3C3C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: const Text(
      "Add Template",
      style: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}

class TemplateCard extends StatelessWidget {
  final String number, text;

  const TemplateCard({
    super.key,
    required this.number,
    required this.text,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}