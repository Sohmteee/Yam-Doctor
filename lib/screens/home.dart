import 'package:app/providers/chats.dart';
import 'package:app/widgets/bold_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      body: chats.isEmpty
          ? Center(
              child: AppBoldText(
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
                    chat.chat.messages.last.,
                  ),
                );
              },
            ),
    );
  }
}
