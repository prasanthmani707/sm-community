import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  final String fullName;
  final String email;
  final String userId;
  final VoidCallback onLogout;
  final VoidCallback onOpenThreads;

  const DrawerMenu({
    super.key,
    required this.fullName,
    required this.email,
    required this.userId,
    required this.onLogout,
    required this.onOpenThreads,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(fullName),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              child: Text(
                userId.isNotEmpty ? userId[0].toUpperCase() : "?",
                style: const TextStyle(fontSize: 24),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),

          // User ID
          ListTile(
            leading: const Icon(Icons.person),
            title: Text("$userId"),
          ),

          // THREADS PAGE

          // LOGOUT
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
