import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatRoom {
  final String id;
  final String title;
  final Chat chat;

  ChatRoom({
    required this.id,
    required this.title,
    required this.chat,
  });
}
