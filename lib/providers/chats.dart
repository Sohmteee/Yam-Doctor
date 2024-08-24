import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

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
