// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/google_sign_in_screen.dart';
import 'screens/community.dart';
import 'screens/ThreadView.dart';
import 'screens/thread_list.dart';

import '../models/message.dart';
import 'utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize logger (Hive safe)
  await AppLogger.init();

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
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

          if (args == null) {
            return const Scaffold(
              body: Center(child: Text("No threads available")),
            );
          }

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
