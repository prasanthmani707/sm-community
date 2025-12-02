
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'community.dart';
import '../widgets/drawer/drawer_menu.dart';
import '../utils/app_logger.dart';

class ChatPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ChatPage({super.key, required this.userData});

  // -------------------------
  // LOGOUT FUNCTION
  // -------------------------
  void _logout(BuildContext context) async {
    AppLogger.i("User ${userData['fullName']} is attempting to logout.");
    try {
      // Sign out from Google
      await GoogleSignIn().signOut();
      AppLogger.i("User ${userData['fullName']} successfully logged out");
      // Navigate to login and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
    } catch (e, st) {
      AppLogger.e(
        "Logout falid for the user ${userData["fullName"]}",
        error: e,
        stackTrace: st,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.i(
      "ChatPage opened for the user : ${userData['fullName']} (${userData['email']})}",
    );

    final List<Map<String, String>> communities = [
      {"name": "SplunkCommunity", "id": "splunk"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("SoftMania"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              AppLogger.d("Drawer opened by the user ${userData['fullName']}");
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: DrawerMenu(
        fullName: userData['fullName'],
        email: userData['email'],
        userId: userData['userId'],
        onLogout: () => _logout(context), // <-- logout here
        onOpenThreads: () {
          AppLogger.d("User ${userData['fullName']} opened thread page");
          Navigator.pushNamed(context, "/threads");
        },
      ),
      body: ListView.builder(
        itemCount: communities.length,
        itemBuilder: (context, index) {
          final community = communities[index];
          return ListTile(
            leading: CircleAvatar(child: Text(community['name']![0])),
            title: Text(community['name']!),
            onTap: () {
              AppLogger.d("User tapped on community: ${community['name']!} (${community['id']!})");



              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CommunityScreen(),
                  settings: RouteSettings(
                    arguments: {
                      ...userData,
                      "communityId": community['id']!,
                      "communityName": community['name']!,
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
