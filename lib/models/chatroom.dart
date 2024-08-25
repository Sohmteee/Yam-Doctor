import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatRoom {
  final String id;
  String title;
  Chat chat;
  List<types.Message> messages = [];

  ChatRoom({
    required this.id,
    required this.title,
    required this.chat,
    required this.messages,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      title: json['title'],
      chat: json['chat'],
      messages: json['messages'],
    );
  }
}
