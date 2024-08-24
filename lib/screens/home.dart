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
    final chats = context.watch<ChatsProvider>().chats;

    return Scaffold(
      appBar: AppBar(
        title: AppBoldText(
          'Recent Chats',
        ),
      ),
      body: chats.isEmpty ? Center(
        child: AppBoldText(
          'No chats yet',
        ),
      ) : Column(
        children: [
          Container(),
        ],
      ),
    );
  }
}
