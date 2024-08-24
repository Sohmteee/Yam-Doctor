import 'package:app/models/chatroom.dart';
import 'package:flutter/material.dart';

class ChatRoomProvider extends ChangeNotifier {
  List<ChatRoom> chats = [];

  void addChat(ChatRoom chat) {
    chats.add(chat);
    notifyListeners();
  }

  void removeChat(ChatRoom chat) {
    chats.remove(chat);
    notifyListeners();
  }
}
