import 'dart:async';
import 'package:flutter/material.dart';

import '../widgets/chat/scroll_to_bottom_button.dart';

import '../models/message.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/message_input.dart';
import '../widgets/chat/reply_banner.dart';
import '../utils/toast_helper.dart';
import '../utils/app_logger.dart';

import '../utils/message_helper.dart';
import '../repositories/message_fetch_repository.dart';
import '../repositories/message_send_repository.dart';

import 'thread_list.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final MessageFetchRepository _fetchRepo = MessageFetchRepository();
  final MessageSendRepository _sendRepo = MessageSendRepository();

  final List<Message> _messages = [];

  bool _showScrollDownButton = false;

  Message? _replyingTo;
  Message? _editingMessage;
  Message? _selectedMessage;

  bool _isMessageSelected = false;

  late String fullName;
  late String email;
  late String userId;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      if (!_isAtBottom) {
        if (!_showScrollDownButton) {
          AppLogger.d("scroll buttom show");
          setState(() => _showScrollDownButton = true);
        }
      } else {
        if (_showScrollDownButton) {
          AppLogger.d("Scroll button hidden");
          setState(() => _showScrollDownButton = false);
        }
      }
    });
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      fullName = args['fullName'];
      email = args['email'];
      userId = args['userId'];
    }

    _fetchMessages();

    _timer ??= Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchMessages(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    AppLogger.d("Fetching message for userId :$userId");

    try {
      final fetched = await _fetchRepo.fetchMessages(userId);
      AppLogger.i("Fetched ${fetched.length} message");

      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(fetched);
      });
    } catch (e) {
      AppLogger.e("Error fetching  message $e");
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final msg = text.trim();
    _controller.clear();
    AppLogger.d("Sending message : $msg");

    try {
      if (_editingMessage != null) {
        AppLogger.i("editing message ID :${_editingMessage!.messageId}");
        await _sendRepo.edit(_editingMessage!.messageId, msg);
        _editingMessage = null;
      } else {
        AppLogger.i(
          "Sending New message (replayto =${_replyingTo?.messageId})",
        );
        await _sendRepo.send(
          userId: userId,
          email: email,
          content: msg,
          replyTo: _replyingTo?.messageId,
          threadId: _replyingTo?.threadId ?? _replyingTo?.messageId,
        );
      }

      _replyingTo = null;

      await _fetchMessages();

      if (!_isAtBottom) {
        AppLogger.d("Scrolling to bottom after sending message");
        _scrollToBottom();
      }
    } catch (e) {
      AppLogger.e("Error sending message :$e");
    }
  }

  bool get _isAtBottom {
    if (!_scrollController.hasClients) return true;
    return _scrollController.offset >=
        _scrollController.position.maxScrollExtent - 100;
  }

  void _onMessageLongPress(Offset pos, Message msg) {
    AppLogger.d("Message long pressed : ${msg.messageId}");
    setState(() {
      _isMessageSelected = true;
      _selectedMessage = msg;

      if (!MessageHelper.canEdit(msg)) {
        AppLogger.d("message ${msg.messageId} connot be edited ");
        _editingMessage = null;
      }
    });
  }

  void _openThread(Message msg) {
    AppLogger.i("Opening thread for messageId=${msg.messageId}");
    Navigator.pushNamed(
      context,
      "/thread",
      arguments: MessageHelper.buildThreadArguments(msg, userId, email),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isMessageSelected
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isMessageSelected = false;
                    _selectedMessage = null;
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),

        title: Text(
          _isMessageSelected ? "1 selected" : "Splunk Community",
          style: const TextStyle(fontSize: 20),
        ),

        actions: _isMessageSelected
            ? [
                if (_selectedMessage != null &&
                    MessageHelper.canEdit(_selectedMessage!))
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _controller.text = _selectedMessage!.content;
                        _editingMessage = _selectedMessage;
                        _isMessageSelected = false;
                        _selectedMessage = null;
                      });
                    },
                  ),

                IconButton(
                  icon: const Icon(Icons.reply),
                  onPressed: () {
                    setState(() {
                      _replyingTo = _selectedMessage;
                      _selectedMessage = null;
                      _isMessageSelected = false;
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.forum),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ThreadListPage(userId: userId, threads: _messages),
                      ),
                    );
                  },
                ),
              ],
      ),

      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      _isMessageSelected = false;
                      _selectedMessage = null;
                    });
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];

                      return MessageBubble(
                        message: msg,
                        isSelected:
                            _selectedMessage?.messageId == msg.messageId,
                        onLongPress: (pos) => _onMessageLongPress(pos, msg),
                        onOpenThread: msg.replyCount > 0
                            ? () => _openThread(msg)
                            : null,
                      );
                    },
                  ),
                ),
              ),

              ReplyBanner(
                replyingTo: _replyingTo,
                onCancel: () => setState(() => _replyingTo = null),
              ),

              MessageInput(
                controller: _controller,
                replyingTo: _replyingTo,
                isEditing: _editingMessage != null,
                onCancelAction: () {
                  setState(() {
                    _replyingTo = null;
                    _editingMessage = null;
                    _controller.clear();
                  });
                },
                onSend: _sendMessage,
                onEdit: (text) async {
                  if (_editingMessage != null) {
                    await _sendRepo.edit(_editingMessage!.messageId, text);
                    await _fetchMessages();
                    setState(() => _editingMessage = null);
                  }
                },
              ),
            ],
          ),

          ScrollToBottomButton(
            visible: _showScrollDownButton,
            onPressed: _scrollToBottom,
          ),
        ],
      ),
    );
  }
}
