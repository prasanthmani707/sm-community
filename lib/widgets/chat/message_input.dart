import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../services/image_upload_service.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final Message? replyingTo;
  final bool isEditing;
  final VoidCallback onCancelAction;
  final void Function(String text) onSend;
  final void Function(String text) onEdit;

  final ImageUploadService _imageService = ImageUploadService();

  MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onEdit,
    this.replyingTo,
    this.isEditing = false,
    required this.onCancelAction,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool disableSend = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    disableSend = widget.controller.text.trim().isEmpty;
  }

  void _onTextChanged() {
    setState(() {
      disableSend = widget.controller.text.trim().isEmpty;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  Future<void> _pickAndSendImage() async {
    final imageUrl = await widget._imageService.pickAndUpload(userId: "user123");

    if (imageUrl != null && mounted) {
      widget.onSend(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.grey[200],
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.photo),
              onPressed: _pickAndSendImage,
            ),
            if (widget.replyingTo != null || widget.isEditing)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancelAction,
              ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.isEditing
                      ? "Edit message..."
                      : (widget.replyingTo != null ? "Reply..." : "Type a message..."),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                minLines: 1,
                maxLines: 6,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: disableSend
                  ? null
                  : () {
                      final text = widget.controller.text.trim();
                      if (text.isEmpty) return;
                      if (widget.isEditing) {
                        widget.onEdit(text);
                      } else {
                        widget.onSend(text);
                      }
                      widget.controller.clear();
                    },
              child: Icon(
                widget.isEditing ? Icons.check : Icons.send,
                color: disableSend ? Colors.grey : Colors.blue,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
