import 'package:app/models/chatroom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.chat,
    super.key,
  });

  final ChatRoom chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.title),
      ),
      body: Chat(
        messages: widget.chat.messages,
        onSendPressed: (message) {
          setState(() {
            // widget.chat.messages.add(message);
          });
        },
        user: widget.chat.chat.user,
      ),
    );
  }
}
