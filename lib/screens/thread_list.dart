import 'package:flutter/material.dart';
import '../models/message.dart';
import '../utils/app_logger.dart';

class ThreadListPage extends StatelessWidget {
  final String userId;
  final List<Message> threads;

  const ThreadListPage({
    super.key,
    required this.userId,
    required this.threads,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.i(
      "ThreadListPage opened for user : $userId. Total message : ${threads.length}",
    );
    // Only show threads with replies and filter by user-created
    final filteredThreads = threads
        .where((t) => t.replyCount > 0 && t.userId == userId)
        .toList();

    AppLogger.d(
      "Filetred thread count :${filteredThreads.length}. "
      "Showing only conversations with replies.",
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Your conversations")),
      body: filteredThreads.isEmpty
          ? const Center(
              child: Text("No threads yet", style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: filteredThreads.length,
              itemBuilder: (context, index) {
                final thread = filteredThreads[index];

                AppLogger.d(
                  "Rending thread : ID=${thread.messageId},"
                  "Replies =${thread.replyCount}",
                );
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(thread.userId[0].toUpperCase()),
                  ),
                  title: Text(thread.content),
                  subtitle: Text("Replies: ${thread.replyCount}"),
                  onTap: () {
                    AppLogger.i(
                      "User tapped the thread : ID=${thread.messageId},"
                      "replies=${thread.replyCount}, contect =${thread.content}",
                    );
                    Navigator.pushNamed(
                      context,
                      "/thread",
                      arguments: {
                        "root": thread,
                        "userId": userId,
                        "email": thread.email,
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
