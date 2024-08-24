import 'package:app/models/chat.dart';
import 'package:flutter/material.dart';

class ChatsProvider extends ChangeNotifier {
  List<Chat> chats = [];


  void addChat(Chat chat) {
    chats.add(chat);
    notifyListeners();
  }

  void removeChat(Chat chat) {
    chats.remove(chat);
    notifyListeners();
  }
}