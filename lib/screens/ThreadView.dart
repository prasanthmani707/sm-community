import 'dart:async';
import 'package:flutter/material.dart';

import '../models/message.dart';
import '../services/api_service.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/message_input.dart';
import '../utils/app_colors.dart';
import '../utils/message_helper.dart';
import '../widgets/chat/scroll_to_bottom_button.dart';
import '../utils/app_logger.dart';

class ThreadView extends StatefulWidget {
  const ThreadView({super.key});

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  final ApiService _apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Message> _threadMessages = [];

  late Message rootMessage;
  late String userId;
  late String email;

  bool _isMessageSelected = false;
  bool _showScrollDownButton = false;

  Message? _selectedMessage;
  Message? _editingMessage;
  Message? _replyingTo;

  Timer? _timer;

  // -------------------------
  // INIT
  // -------------------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    rootMessage = args['root'];
    userId = args['userId'];
    email = args['email'];

    AppLogger.i(
      "ThreadView opened . root mesage :${rootMessage.messageId},"
      "user :$userId"
    );

    _fetchThreadMessages();

    _timer ??= Timer.periodic(
      const Duration(seconds: 3),
      (_) => _fetchThreadMessages(),
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      if (_scrollController.offset <
          _scrollController.position.maxScrollExtent - 20) {
        if (!_showScrollDownButton)
          setState(() => _showScrollDownButton = true);
      } else {
        if (_showScrollDownButton)
          setState(() => _showScrollDownButton = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // -------------------------
  // FETCH THREAD MESSAGES
  // -------------------------
  Future<void> _fetchThreadMessages() async {
    AppLogger.d("Fetching thread message for root : ${rootMessage.messageId}");

    try {
      final allMessages = await _apiService.fetchMessages(userId);

      final msgs = allMessages
          .where(
            (msg) =>
                msg.threadId == rootMessage.messageId ||
                msg.messageId == rootMessage.messageId,
          )
          .toList();

      msgs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (!mounted) return;

      setState(() {
        _threadMessages
          ..clear()
          ..addAll(msgs.where((m) => m.messageId != rootMessage.messageId));
      });

      AppLogger.d(
        "Thread messages updated : ${_threadMessages.length} message",
      );
    } catch (e, st) {
      AppLogger.e("Error fetching thread messsage", error: e, stackTrace: st);
    }
  }

  // -------------------------
  // SEND / EDIT MESSAGE
  // -------------------------
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    AppLogger.d("Sensding message :\"$text\"");

    try {
      if (_editingMessage != null) {
        AppLogger.d("Editing message : ${_editingMessage!.messageId}");
        await _apiService.editMessage(_editingMessage!.messageId, text);
        _editingMessage = null;
      } else {
        AppLogger.i("Sending new message in thread ${rootMessage.messageId}");

        await _apiService.sendMessage(
          userId,
          email,
          text,
          replyTo: _replyingTo?.messageId ?? rootMessage.messageId,
          threadId: rootMessage.messageId,
        );
        _replyingTo = null;
      }

      _controller.clear();
      await _fetchThreadMessages();
    } catch (e, st) {
      AppLogger.e("Error sending message ", error: e, stackTrace: st);
    }
  }

  // -------------------------
  // SCROLL TO BOTTOM
  // -------------------------
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    AppLogger.d("Scrolling to buttom (animation:$animated)");

    final position = _scrollController.position.maxScrollExtent;

    if (animated) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(position);
    }
  }

  // -------------------------
  // LONG PRESS — use MessageHelper
  // -------------------------
  void _onMessageLongPress(Message message) {
    final isImage = MessageHelper.isImageMessage(message.content);
    AppLogger.d("message long pressed : ${message.messageId}");
    setState(() {
      _isMessageSelected = true;
      _selectedMessage = message;

      if (isImage) {
        _editingMessage = null;
        AppLogger.d("Message is image -editing disabled.");
      }
    });
  }

  // -------------------------
  // BUILD UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isMessageSelected ? "1 selected" : "Thread"),
        leading: _isMessageSelected
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  AppLogger.d("Selection cleared");
                  setState(() {
                    _isMessageSelected = false;
                    _selectedMessage = null;
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  AppLogger.i("User left thread ${rootMessage.messageId}");
                  Navigator.pop(context);
                },
              ),
        actions: _isMessageSelected
            ? [
                if (_selectedMessage != null &&
                    MessageHelper.canEdit(_selectedMessage!))
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      AppLogger.d(
                        "Editing message: ${_selectedMessage!.messageId}",
                      );
                      _controller.text = _selectedMessage!.content;
                      _editingMessage = _selectedMessage;
                      setState(() {
                        _isMessageSelected = false;
                        _selectedMessage = null;
                      });
                    },
                  ),
              ]
            : [],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ROOT MESSAGE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.chatBackground,
                child: MessageBubble(
                  message: rootMessage,
                  onLongPress: (_) => _onMessageLongPress(rootMessage),
                ),
              ),

              const Divider(height: 1),

              // THREAD MESSAGES
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _threadMessages.length,
                  itemBuilder: (context, index) {
                    final msg = _threadMessages[index];

                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _selectedMessage = null),
                      child: MessageBubble(
                        message: msg,
                        isSelected:
                            _selectedMessage?.messageId == msg.messageId,
                        onLongPress: (_) => _onMessageLongPress(msg),
                      ),
                    );
                  },
                ),
              ),

              // MESSAGE INPUT
              MessageInput(
                controller: _controller,
                replyingTo: _replyingTo,
                isEditing: _editingMessage != null,
                onCancelAction: () {
                  AppLogger.d("Cancel editing/reply");
                  setState(() {
                    _replyingTo = null;
                    _editingMessage = null;
                    _controller.clear();
                  });
                },
                onSend: _sendMessage,
                onEdit: (text) async {
                  if (_editingMessage != null) {
                    await _apiService.editMessage(
                      _editingMessage!.messageId,
                      text,
                    );
                    _controller.clear();
                    setState(() => _editingMessage = null);
                    await _fetchThreadMessages();
                  }
                },
              ),
            ],
          ),

          // SCROLL-TO-BOTTOM BUTTON
          ScrollToBottomButton(
            visible: _showScrollDownButton,
            onPressed: _scrollToBottom,
          ),
        ],
      ),
    );
  }
}
