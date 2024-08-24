import 'package:app/widgets/bold_text.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final chats = context
    return Scaffold(
      appBar: AppBar(
        title: AppBoldText(
          'Recent Chats',
        ),
      ),
      body: Column(
        children: [
          Container(),
        ],
      ),
    );
  }
}
