import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatRoom {
  final String id;
  String title;
  Chat chat;
  List<Message> messages = [];

  ChatRoom({
    required this.id,
    required this.title,
    required this.chat,
    required this.messages,
  });
}
