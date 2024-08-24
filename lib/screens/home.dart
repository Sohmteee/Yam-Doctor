import 'package:app/models/chatroom.dart';
import 'package:app/providers/chatroom.dart';
import 'package:app/screens/chat.dart';
import 'package:app/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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
              String id = const Uuid().v4();
              List<types.Message> messages = [];

              chatRoomProvider.addChat(
                ChatRoom(
                  id: id,
                  title: 'Chat ${chatRoomProvider.chats.length + 1}',
                  messages: messages,
                  chat: Chat(
                    onSendPressed: (message) {},
                    user: types.User(
                      id: const Uuid().v4(),
                      firstName: 'You',
                      // imageUrl: 'https://i.pravatar.cc/150?img=1',
                      role: types.Role.user,
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
                    chatRoom: chatRoomProvider.chats
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
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final chat = chatRoomProvider.chats[index];

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatRoom: chat,
                          ),
                        ),
                      );
                    },
                    title: AppBoldText(
                      chat.title,
                    ),
                    trailing: PopupMenuButton<int>(
                      onSelected: (int result) {
                        // Handle the selected option here
                        print('Selected: $result');
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<int>>[
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<int>(
                          value: 2,
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      );
    });
  }
}
