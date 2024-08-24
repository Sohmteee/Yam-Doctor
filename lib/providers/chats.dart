import 'package:app/models/chatroom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatsProvider extends ChangeNotifier {
  List<Chatroom> chats = [];

  void addChat(Chatroom chat) {
    chats.add(chat);
    notifyListeners();
  }

  void removeChat(Chat chat) {
    chats.remove(chat);
    notifyListeners();
  }
}
