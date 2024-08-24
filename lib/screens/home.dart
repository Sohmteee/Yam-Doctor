import 'package:app/models/chatroom.dart';
import 'package:app/providers/chatroom.dart';
import 'package:app/screens/chat.dart';
import 'package:app/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:xid/xid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatRoomProvider>(builder: (context, chatRoomProvider, _) {
      return Scaffold(
        appBar: AppBar(
          title: AppBoldText(
            'Recent Chats',
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
            right: 6.w,
            bottom: 10.h,
          ),
          child: FloatingActionButton(
            onPressed: () {
              String id = Xid().toString();
              List<types.Message> messages = [];

              chatRoomProvider.addChat(
                ChatRoom(
                  id: id,
                  title: 'New Chat',
                  messages: messages,
                  chat: Chat(
                    onSendPressed: (message) {},
                    user: types.User(
                      id: Xid().toString(),
                    ),
                    messages: const [],
                  ),
                ),
              );

              debugPrint(
                  'Chats: ${chatRoomProvider.chats.map((chat) => chat.title).toList()}');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chat: chatRoomProvider.chats
                        .singleWhere((chat) => chat.id == id),
                  ),
                ),
              );
            },
            child: const Icon(
              Icons.add,
            ),
          ),
        ),
        body: chatRoomProvider.chats.isEmpty
            ? Center(
                child: AppText(
                  'No chats yet',
                  color: Colors.grey,
                ),
              )
            : ListView.builder(
                itemCount: chatRoomProvider.chats.length,
                itemBuilder: (context, index) {
                  final chat = chatRoomProvider.chats[index];

                  return ListTile(
                    title: AppBoldText(
                      chat.title,
                    ),
                    subtitle: (chat.chat.messages.isNotEmpty) ? Text(
                      chat.chat.messages.last.metadata?['message'] ?? '',
                    ),
                  );
                },
              ),
      );
    });
  }
}
