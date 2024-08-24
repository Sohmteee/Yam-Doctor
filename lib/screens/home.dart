import 'package:app/models/chatroom.dart';
import 'package:app/providers/chats.dart';
import 'package:app/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
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
    final chats = context.watch<ChatRoomProvider>().chats;

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
            chats.add(
              ChatRoom(
                id: id,
                title: 'New Chat',
                chat: Chat(
                  onSendPressed: (message) {
                    ;
                  },
                  user: User(
                    id: Xid().toString(),
                  ),
                  messages: const [],
                ),
              ),
            );
          },
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
      body: chats.isEmpty
          ? Center(
              child: AppText(
                'No chats yet',
                color: Colors.grey,
              ),
            )
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];

                return ListTile(
                  title: AppBoldText(
                    chat.title,
                  ),
                  subtitle: Text(
                    chat.chat.messages.last.metadata?['message'],
                  ),
                );
              },
            ),
    );
  }
}
