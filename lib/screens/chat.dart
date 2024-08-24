import 'dart:convert';
import 'dart:io';

import 'package:app/models/chatroom.dart';
import 'package:app/providers/chatroom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final gemini = Gemini.instance;
  double temp = .7;

  final TextEditingController _controller = TextEditingController();
  final List<types.ImageMessage> _images = [];
  final List<Uint8List> _imagesBytes = [];
  String _imageText = '';
  final types.User yamDoctor = const types.User(
    id: 'yamDoctor',
    firstName: 'Yam Doctor',
    // imageUrl: 'https://i.pravatar.cc/150?img=1',
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
              onPressed: () {},
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
          imageMessageBuilder: (types.ImageMessage message,
              {messageWidth = 2}) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.file(
                  File(message.uri),
                ),
                if (_imageText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      message.name,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
              ],
            );
          },
          customBottomWidget: SizedBox(
            child: Column(
              children: [
                if (_images.isNotEmpty)
                  SizedBox(
                    height: 70.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(width: 10.w);
                      },
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1.sp,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(11.r),
                                    child: Image.file(
                                      File(_images[index].uri),
                                      height: 50.h,
                                      width: 50.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -10.h,
                                  right: -10.w,
                                  child: ZoomTapAnimation(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                    child: Card(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: const CircleBorder(),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                SizedBox(height: 4.h),
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
                      visible:
                          _controller.text.isNotEmpty || _images.isNotEmpty,
                      child: Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: ZoomTapAnimation(
                          child: Icon(
                            IconlyLight.send,
                            color: Colors.deepPurple,
                            size: 25.sp,
                          ),
                          onTap: () {
                            if (_images.isNotEmpty) {
                              _imageText = _controller.text.trim();

                              for (var image in _images) {
                                _addMessage(image);
                              }
                              _getImageResponse(
                                  _imagesBytes, _controller.text.trim());

                              _images.clear();
                              _imagesBytes.clear();
                              _controller.clear();
                            } else {
                              _handleSendPressed(
                                types.PartialText(
                                  text: _controller.text.trim(),
                                ),
                              );
                              _controller.clear();

                              _getResponse();
                            }
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
      ),
    );
  }

  String get preResponse {
    return '''
    You are a chat bot operating as a yam disease diagnosis expert system that tells the user if a yam is good or bad.
    You tell them what disease(s) the yam might have and how to treat it based on pictures and/or descriptions from the user. You can accept greetings, ask for pictures, and give a response based on the pictures and/or descriptions. Don't answer questions that don't relate to yams. If you don't understand the user's message, ask them to rephrase it. If you can't help the user, tell them you can't help them. If you can help the user, tell them how you can help them. If you need more information, ask the user for it. If you need to ask the user a question, ask the user a question. If you need to give the user a warning, give the user a warning. If you need to give the user a suggestion, give the user a suggestion. If you need to give the user a compliment, give the user a compliment. If you need to give the user a command, give the user a command. If you need to give the user a request, give the user a request. If you need to give the user a response, give the user a response. If you need to give the user a reason, give the user a reason. If you need to give the user an explanation, give the user an explanation. If you need to give the user a description, give the user a description. If you need to give the user a definition, give the user a definition. If you need to give the user an example, give the user an example. If you need to give the user a warning, give the user a warning. If you need to give the user a suggestion, give the user a suggestion. If you need to give the user a compliment, give the user a compliment. If you need to give the user a command, give the user a command. If you need to give the user a request, give the user a request. If you need to give the user a response, give the user a response. If you need to give the user a reason, give the user a reason. If you need to give the user an explanation, give the user an explanation. If you need to give the user a description, give the user a description. If you need to give the user a definition, give the user a definition. Give short responses, but you can elaborate if you need to or if the user tells you to. If you need to give the user an example, give the user an example. Below is the conversation so far:
''';
  }

  List<String> segmentChat({int length = 20}) {
    final messages = widget.chatRoom.messages.reversed.take(20).toList();

    final List<String> contents = [];

    for (var message in messages) {
      if (message is types.TextMessage) {
        contents.add(
          /* ${message.author.id == yamDoctor.id ? 'Yam Doctor' : 'User'}:  */
          message.text,
        );
      }
    }

    debugPrint(contents.toString());
    return contents;
  }

  void _getResponse() async {
    final messages = segmentChat();

    final response = await gemini
        .text(
          '''
$preResponse
${messages.map((message) => message).join('\n')}
        ''',
          generationConfig: GenerationConfig(
            temperature: temp,
          ),
        )
        .then((value) => value?.content?.parts?.last.text)
        .catchError((error) => error.toString());
    debugPrint(response);

    final message = types.TextMessage(
      id: const Uuid().v4(),
      author: yamDoctor,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: response!,
    );

    _addMessage(message);
  }

  void _getImageResponse(List<Uint8List> images, String text) async {
    // final messages = segmentChat();

    final response = await gemini
        .textAndImage(
          images: images,
          text: '''
          Describe the image(s)
          If it contains yam(s), tell the user if the yam is good or bad, if it has any diseases.
          If they aren't pictures of yams, let the user know.
          $preResponse
          $text
          ''',
          generationConfig: GenerationConfig(
            temperature: temp,
          ),
        )
        .then((value) => value?.content?.parts?.last.text)
        .catchError((error) => error.toString());
    debugPrint(response);
    final message = types.TextMessage(
      id: const Uuid().v4(),
      author: yamDoctor,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: response ?? 'I cannot help you with that',
    );

    _addMessage(message);
  }

  Future<void> _nameChat() async {
    final messages = segmentChat(length: 5);

    final response = await gemini
        .text(
          '''
Please name the chat based on the chat so far. You can name it based on the yam disease if any has been diagnosed. Whatever your response is, it should be nothing more than 5 words. The chat so far is as follows:\n
${messages.map((message) => message).join('\n')}
        ''',
          generationConfig: GenerationConfig(
            temperature: temp,
          ),
        )
        .then((value) => value?.content?.parts?.last.text)
        .catchError((error) => error.toString());

    debugPrint('Chat Name: $response');
    setState(() {
      context.read<ChatRoomProvider>().renameChat(widget.chatRoom, response!);
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      widget.chatRoom.messages.insert(0, message);
    });

    if (widget.chatRoom.title ==
        'Chat ${context.read<ChatRoomProvider>().chats.length}') {
      print('Name chat..........................................');
      _nameChat();
    }
  }

  void _showImagePreview(types.ImageMessage message) {
    setState(() {
      _images.add(message);
    });
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
      final results = await ImagePicker().pickMultiImage(
        imageQuality: 70,
        maxWidth: 1440,
      );

      for (var result in results) {
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

        _imagesBytes.add(bytes);
        _showImagePreview(message);
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

  void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      widget.chatRoom.messages = messages;
    });
  }
}
