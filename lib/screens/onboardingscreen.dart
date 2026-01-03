import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  List<Map<String, String>> onboardingData = [
    {
      "title": "Welcome to WishMate",
      "subtitle": "Never forget a birthday again!\nWe send wishes for you.",
      "icon": "cake",
    },
    {
      "title": "Automatic Wishes",
      "subtitle": "Wish your friends at midnight automatically\nvia WhatsApp.",
      "icon": "watch_later",
    },
    {
      "title": "Smart Reminders",
      "subtitle":
          "Reminder notifications keep you updated\nbefore every birthday.",
      "icon": "notifications_active",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FA3D9),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return buildOnboardingPage(
                    onboardingData[index]["title"]!,
                    onboardingData[index]["subtitle"]!,
                    onboardingData[index]["icon"]!,
                  );
                },
              ),
            ),

            // Dot Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => buildDot(index),
              ),
            ),

            const SizedBox(height: 20),

            // Next / Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                  ),
                 onPressed: () async {
  if (currentPage == onboardingData.length - 1) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    Navigator.pushReplacementNamed(context, "/login");
  } else {
    _controller.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
},

                  child: Text(
                    currentPage == onboardingData.length - 1
                        ? "Get Started"
                        : "Next",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildOnboardingPage(String title, String subtitle, String iconName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getIcon(iconName), size: 120, color: Colors.white),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 6),
      height: 10,
      width: currentPage == index ? 22 : 10,
      decoration: BoxDecoration(
        color: currentPage == index ? Colors.white : Colors.white60,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case "cake":
        return Icons.cake_rounded;
      case "watch_later":
        return Icons.watch_later_rounded;
      case "notifications_active":
        return Icons.notifications_active_rounded;
      default:
        return Icons.info;
    }
  }
}
