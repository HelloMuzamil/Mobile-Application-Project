import 'package:flutter/material.dart';

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
            drawerItem(Icons.home, "Home"),
            drawerItem(Icons.group, "Friend List"),
            drawerItem(Icons.description, "Template List"),
            drawerItem(Icons.create, "Create Template"),
            drawerItem(Icons.logout, "LogOut"),
          ],
        ),
      ),
    );
  }

  Widget drawerItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 14),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
