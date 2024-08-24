import 'dart:convert';
import 'dart:io';

import 'package:app/models/chatroom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
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
  final TextEditingController _controller = TextEditingController();
  bool _isImagePreviewVisible = false;

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
          customBottomWidget: SizedBox(
            child: Column(
              children: [
                if (_isImagePreviewVisible)
                  SizedBox(
                    height: 50.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.chatRoom.messages
                          .whereType<types.ImageMessage>()
                          .length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: Colors.grey[200],
                          ),
                          child: Image.file(
                            File(widget.chatRoom.messages
                                .whereType<types.ImageMessage>()
                                .first
                                .uri),
                            height: 50.h,
                            width: 50.w,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 10.h),
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

  void _addMessage(types.Message message) {
    setState(() {
      widget.chatRoom.messages.insert(0, message);
    });
  }

  void _showImagePreview(types.ImageMessage message) {
    setState(() {
      _isImagePreviewVisible = true;
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

        // _addMessage(message);
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
