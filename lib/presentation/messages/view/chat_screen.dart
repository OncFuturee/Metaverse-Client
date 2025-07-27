import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:metaverse_client/presentation/messages/view_models/chat_message_model.dart';
import 'package:metaverse_client/routes/app_router.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      sender: 'anny_wilson',
      senderAvatar: 'https://picsum.photos/200/200?random=666',
      text: 'She is adorable! Don’t you want to meet her?? 😂',
      isMe: false,
    ),
    ChatMessage(
      sender: 'You',
      senderAvatar: 'https://picsum.photos/200/200?random=888',
      text: 'Please, don’t make me do it, I’m sure you know my character 😂',
      isMe: true,
    ),
  ];

  final TextEditingController _messageController = TextEditingController();
  bool _isInputEmpty = true;
  bool _isRecording = false;
  bool _isRecordingCanceled = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _onMessageTextChanged() {
    setState(() {
      _isInputEmpty = _messageController.text.isEmpty;
    });
  }

  void _sendTextMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            sender: 'You',
            senderAvatar: 'https://picsum.photos/200/200?random=1000',
            text: _messageController.text,
            isMe: true,
          ),
        );
      });
      _messageController.clear();
    }
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
      _isRecordingCanceled = false;
    });
    print('开始录音...');
  }

  void _onVoiceRecordingMove(LongPressMoveUpdateDetails details) {
    if (details.localPosition.dy < -80.0) {
      if (!_isRecordingCanceled) {
        setState(() {
          _isRecordingCanceled = true;
        });
        print('上滑取消发送语音');
      }
    } else {
      if (_isRecordingCanceled) {
        setState(() {
          _isRecordingCanceled = false;
        });
        print('恢复录音');
      }
    }
  }

  void _endVoiceRecording() {
    setState(() {
      _isRecording = false;
    });
    if (!_isRecordingCanceled) {
      print('松手发送语音');
      _messages.add(
        ChatMessage(
          sender: 'You',
          senderAvatar: 'https://picsum.photos/200/200?random=1000',
          text: '[语音消息] - (时长: 10s)',
          isMe: true,
        ),
      );
    } else {
      print('语音发送已取消');
    }
  }

  /// 显示输入用户 ID 的对话框
  void _showVideoCallDialog() {
    final TextEditingController userIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('发起视频通话'),
          content: TextField(
            controller: userIdController,
            decoration: const InputDecoration(hintText: '请输入对方的 User ID'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                context.router.pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                final userId = userIdController.text;
                if (userId.isNotEmpty) {
                  // 关闭对话框并导航到视频通话页面
                  context.router.pop();
                  context.router.push(
                    VideoCallRoute(userId: userId, isCaller: true),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.pop(),
        ),
        title: const Text('Annette Black'),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: _showVideoCallDialog, // 调用新创建的方法
          ),
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'more', child: Text('More')),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment:
                      message.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          message.isMe ? Colors.pinkAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!message.isMe)
                          CircleAvatar(
                            backgroundImage: NetworkImage(message.senderAvatar),
                          ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: message.isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        if (message.isMe) const SizedBox(width: 8),
                        if (message.isMe)
                          CircleAvatar(
                            backgroundImage: NetworkImage(message.senderAvatar),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type message...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {},
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {},
                ),
                _isInputEmpty
                    ? GestureDetector(
                      onLongPressStart: (_) => _startVoiceRecording(),
                      onLongPressMoveUpdate: _onVoiceRecordingMove,
                      onLongPressEnd: (_) => _endVoiceRecording(),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              _isRecording && !_isRecordingCanceled
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.mic,
                          color:
                              _isRecordingCanceled ? Colors.grey : Colors.pink,
                          size: 28,
                        ),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(Icons.send, color: Colors.pink),
                      onPressed: _sendTextMessage,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
