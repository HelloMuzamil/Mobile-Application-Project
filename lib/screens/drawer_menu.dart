import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF8FA3D9),
      child: Padding(
        padding: const EdgeInsets.only(top: 60, left: 20),
        child: Column(
          children: [
            drawerItem(
              context,
              icon: Icons.home,
              title: "Home",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/home");
              },
            ),

            drawerItem(
              context,
              icon: Icons.group,
              title: "Friend List",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/seeAll");
              },
            ),

            drawerItem(
              context,
              icon: Icons.description,
              title: "Template List",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/viewTemplates");
              },
            ),

            drawerItem(
              context,
              icon: Icons.create,
              title: "Create Template",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/addTemplate");
              },
            ),

            drawerItem(
              context,
              icon: Icons.logout,
              title: "Logout",
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 14),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
