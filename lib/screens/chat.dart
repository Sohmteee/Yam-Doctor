import 'package:app/models/chatroom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 2.h,
        ),
        child: Chat(
          messages: widget.chat.messages,
          onSendPressed: (message) {
            setState(() {
              // widget.chat.messages.add(message);
            });
          },
          user: widget.chat.chat.user,
        ),
      ),
    );
  }
}
