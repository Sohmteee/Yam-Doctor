import 'dart:io';

import 'package:app/main.dart';
import 'package:app/models/chatroom.dart';
import 'package:app/providers/chatroom.dart';
import 'package:app/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' /* show Uint8List, rootBundle */;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.chatRoom,
    super.key,
  });

  final ChatRoom chatRoom;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final gemini = GenerativeModel(
      model: "gemini-1.5-flash",
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: .7,
      ));
  // double temp = .7;

  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  final types.User yamDoctor = const types.User(
    id: 'yamDoctor',
    firstName: 'Yam Doctor',
    role: types.Role.admin,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoom.title),
        actions: [
          ZoomTapAnimation(
            child: IconButton(
              splashColor: Colors.transparent,
              splashRadius: 1,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppBoldText(
                                'Rename Chat',
                                fontSize: 20.sp,
                              ),
                              SizedBox(height: 20.h),
                              TextField(
                                controller: TextEditingController(
                                    text: widget.chatRoom.title),
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: 'Enter new chat title',
                                ),
                                textCapitalization: TextCapitalization.words,
                                onSubmitted: (value) {
                                  context.read<ChatRoomProvider>().renameChat(
                                        widget.chatRoom,
                                        value,
                                      );
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
              icon: const Icon(
                IconlyLight.edit,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 8.sp,
          right: 8.sp,
          bottom: 8.sp,
        ),
        child: Chat(
          messages: widget.chatRoom.messages,
          scrollPhysics: const BouncingScrollPhysics(),
          onSendPressed: (message) {
            _handleSendPressed(message);
            debugPrint(widget.chatRoom.messages
                .map((e) => e.toJson()['text'])
                .toList()
                .toString());
          },
          user: widget.chatRoom.chat.user,
          dateHeaderBuilder: (p0) {
            String headerText;
            getDateDifference() {
              final dayDiff = DateTime.now().difference(p0.dateTime).inDays;
              if (dayDiff == 0) {
                return 'Today';
              } else if (dayDiff == 1) {
                return 'Yesterday';
              } else {
                return '${switch (p0.dateTime.month) {
                  1 => 'January',
                  2 => 'February',
                  3 => 'March',
                  4 => 'April',
                  5 => 'May',
                  6 => 'June',
                  7 => 'July',
                  8 => 'August',
                  9 => 'September',
                  10 => 'October',
                  11 => 'November',
                  12 => 'December',
                  _ => '',
                }} ${p0.dateTime.day}${p0.dateTime.year == DateTime.now().year ? '' : ', ${p0.dateTime.year}'}';
              }
            }

            headerText = getDateDifference();

            return Container(
              padding: EdgeInsets.only(
                top: 8.sp,
                bottom: 8.sp,
              ),
              child: Center(
                child: Text(
                  headerText,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            );
          },
          onAttachmentPressed: _handleAttachmentPressed,
          onMessageTap: _handleMessageTap,
          onMessageLongPress: (context, message) {
            debugPrint('Message long pressed: ${message.toJson()['text']}');
          },
          onPreviewDataFetched: _handlePreviewDataFetched,
          emojiEnlargementBehavior: EmojiEnlargementBehavior.multi,
          customBottomWidget: Column(
            children: [
              if (_isTyping)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      bottom: 8,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Yam Doctor is typing',
                          style: TextStyle(
                            color: Colors.grey,
                            // fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        SpinKitThreeBounce(
                          color: Colors.deepPurple,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              TextField(
                controller: _controller,
                onSubmitted: (value) {
                  _handleSendPressed(
                    types.PartialText(
                      text: value.trim(),
                    ),
                  );
                  _controller.clear();
                },
                onChanged: (value) {
                  setState(() {});
                },
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.sp),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.sp),
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                      width: 2.sp,
                    ),
                  ),
                  // filled: true,
                  // fillColor: Colors.grey[300],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  prefixIcon: ZoomTapAnimation(
                    onTap: _handleImageSelection,
                    child: Icon(
                      IconlyLight.image,
                      color: Colors.black,
                      size: 25.sp,
                    ),
                  ),
                  suffixIcon: Visibility(
                    visible: _controller.text.isNotEmpty,
                    child: Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: ZoomTapAnimation(
                        child: Icon(
                          IconlyLight.send,
                          color: Colors.deepPurple,
                          size: 25.sp,
                        ),
                        onTap: () {
                          _handleSendPressed(
                            types.PartialText(
                              text: _controller.text.trim(),
                            ),
                          );
                          _controller.clear();
                          _getResponse();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get preResponse {
    return '''
    You are a chat bot operating as a yam disease diagnosis expert system that tells the user if a yam is good or bad.
    You tell them what disease(s) the yam might have and how to treat it based on pictures and/or descriptions from the user. You can accept greetings, ask for pictures, and give a response based on the pictures and/or descriptions. Don't answer questions that don't relate to yams. If you don't understand the user's message, ask them to rephrase it. If you can't help the user, tell them you can't help them. If you can help the user, tell them how you can help them. If you need more information, ask the user for it. If you need to ask the user a question, ask the user a question. If you need to give the user a warning, give the user a warning. If you need to give the user a suggestion, give the user a suggestion. If you need to give the user a compliment, give the user a compliment. If you need to give the user a command, give the user a command. If you need to give the user a request, give the user a request. If you need to give the user a response, give the user a response. If you need to give the user a reason, give the user a reason. If you need to give the user an explanation, give the user an explanation. If you need to give the user a description, give the user a description. If you need to give the user a definition, give the user a definition. If you need to give the user an example, give the user an example. If you need to give the user a warning, give the user a warning. If you need to give the user a suggestion, give the user a suggestion. If you need to give the user a compliment, give the user a compliment. If you need to give the user a command, give the user a command. If you need to give the user a request, give the user a request. If you need to give the user a response, give the user a response. If you need to give the user a reason, give the user a reason. If you need to give the user an explanation, give the user an explanation. If you need to give the user a description, give the user a description. If you need to give the user a definition, give the user a definition. Give short responses, but you can elaborate if you need to or if the user tells you to. If you need to give the user an example, give the user an example. Below is the conversation so far:
''';
  }

  Future<List<Content>> segmentChat({int length = 20}) async {
    final messages =
        widget.chatRoom.messages.take(length).toList().reversed.toList();

    final List<Content> contents = [];

    for (var message in messages) {
      // String role = message.author.id == yamDoctor.id ? 'yam doctor' : 'user';

      if (message is types.TextMessage) {
        contents.add(
          Content.text(message.text),
        );
      } else if (message is types.ImageMessage) {
        contents.add(
            Content.data('image/png', await File(message.uri).readAsBytes()));
      }
    }

    debugPrint(contents.toString());
    return contents;
  }

  void _getResponse() async {
    final messages = await segmentChat();

    setState(() {
      _isTyping = true;
    });

    final response = await gemini
        .generateContent([
          Content.text(preResponse),
          ...messages,
        ])
        .then((value) =>
            value.candidates.first.text?.trim() ??
            'I can\'t help you with that.')
        .catchError((error) =>
            'It looks like an error occurred. Check your internet connection and try again.');

    setState(() {
      _isTyping = false;
    });

    debugPrint(response);

    final message = types.TextMessage(
      id: const Uuid().v4(),
      author: yamDoctor,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: response.trim(),
    );

    _addMessage(message);
  }

  /*  void _getImageResponse(Uint8List image) async {
    setState(() {
      _isTyping = true;
    });

    final response = await gemini
        .textAndImage(
          images: [image],
          text: '''
          Describe the image(s)
          If it contains yam(s), tell the user if the yam is good or bad, if it has any diseases.
          If they aren't pictures of yams, let the user know.
          $preResponse
          ''',
          generationConfig: GenerationConfig(
            temperature: temp,
          ),
        )
        .then((value) => value?.content?.parts?.last.text)
        .catchError((error) => error.toString());

    setState(() {
      _isTyping = false;
    });

    debugPrint(response);
    final message = types.TextMessage(
      id: const Uuid().v4(),
      author: yamDoctor,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: response ?? 'I cannot help you with that',
    );

    _addMessage(message);
  }
 */
  Future<void> _nameChat() async {
    final messages = await segmentChat(length: 5);

    final response = await gemini
        .generateContent([
          Content.text('''
Please name the chat based on the chat so far. You can name it based on the yam disease if any has been diagnosed. Whatever your response is, it should be nothing more than 5 words. Don't use the word 'chat' in naming. The chat so far is as follows:\n
        '''),
          ...messages,
        ])
        .then((value) => value.candidates.first.text)
        .catchError((error) => 'New Chat');

    debugPrint('Chat Name: $response');
    setState(() {
      context
          .read<ChatRoomProvider>()
          .renameChat(widget.chatRoom, response!.trim());
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      widget.chatRoom.messages.insert(0, message);
    });

    if (widget.chatRoom.title == 'New Chat') {
      debugPrint('Name chat..........................................');
      _nameChat();
    }
  }

  void _handleAttachmentPressed() {
    _handleImageSelection();
  }

  /*  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: widget.chatRoom.chat.user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }
 */
  void _handleImageSelection() async {
    try {
      final result = await ImagePicker().pickImage(
        imageQuality: 70,
        maxWidth: 1440,
        source: ImageSource.gallery,
      );

      if (result != null) {
        final bytes = await result.readAsBytes();
        final image = await decodeImageFromList(bytes);

        final message = types.ImageMessage(
          author: widget.chatRoom.chat.user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          height: image.height.toDouble(),
          id: const Uuid().v4(),
          name: result.name,
          size: bytes.length,
          uri: result.path,
          width: image.width.toDouble(),
        );

        _addMessage(message);
        _getResponse();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index = widget.chatRoom.messages
              .indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (widget.chatRoom.messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            widget.chatRoom.messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index = widget.chatRoom.messages
              .indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (widget.chatRoom.messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            widget.chatRoom.messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = widget.chatRoom.messages
        .indexWhere((element) => element.id == message.id);
    final updatedMessage =
        (widget.chatRoom.messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      widget.chatRoom.messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: widget.chatRoom.chat.user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  /* void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      widget.chatRoom.messages = messages;
    });
  } */
}
