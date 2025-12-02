// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/google_sign_in_screen.dart';

import 'screens/community.dart';
import 'screens/ThreadView.dart';
import 'screens/thread_list.dart';
import '../models/message.dart'; // Message model
import 'utils/app_logger.dart'; // optional, can use anywhere

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.init(); // <- important
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Splunk Community',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/login",
      routes: {
        "/login": (context) => GoogleSignInScreen(),
        "/community": (context) => const CommunityScreen(),
        "/chat": (context) => const CommunityScreen(),
        "/thread": (context) => const ThreadView(),
        "/threads": (context) {
          // Extract arguments passed during navigation
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

          if (args == null) {
            // fallback if no args passed
            return const Scaffold(
              body: Center(child: Text("No threads available")),
            );
          }

          // threads must be passed as List<Message>
          final List<Message> threads = args["threads"] as List<Message>? ?? [];

          return ThreadListPage(
            userId: args["userId"] as String,
            threads: threads,
          );
        },
      },
    );
  }
}
