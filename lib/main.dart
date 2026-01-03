import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/SplashScreen.dart';
import 'screens/onboardingscreen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/homescreen.dart';
import 'screens/see_all_screen.dart';
import 'screens/add_birthday_screen.dart';
import 'screens/view_templates_screen.dart';
import 'screens/add_template_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WishMateApp());
}

class WishMateApp extends StatelessWidget {
  const WishMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF8FA3D9),
        fontFamily: 'Roboto',
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => SplashScreen(),
        "/onboarding": (context) => OnboardingScreen(),
        "/login": (context) => LoginScreen(),
        "/signup": (context) => SignupScreen(),
        "/home": (context) => Homescreen(),

 
        "/seeAll": (context) => const SeeAllScreen(),
        "/addBirthday": (context) => const AddBirthdayScreen(),
        "/viewTemplates": (context) => const ViewTemplatesScreen(),
        "/addTemplate": (context) => const AddTemplateScreen(),

      },
    );
  }
}
