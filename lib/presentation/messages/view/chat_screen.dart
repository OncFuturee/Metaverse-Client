import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:metaverse_client/presentation/messages/view_models/chat_message_model.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // 模拟聊天消息数据，实际可从网络或其他数据源获取
  final List<ChatMessage> _messages = [
    ChatMessage(
      sender: 'anny_wilson',
      senderAvatar: 'https://picsum.photos/200/200?random=666', // 实际头像链接
      text: 'She is adorable! Don’t you want to meet her?? 😂',
      isMe: false,
    ),
    ChatMessage(
      sender: 'You',
      senderAvatar: 'https://picsum.photos/200/200?random=888', // 自己头像链接
      text: 'Please, don’t make me do it, I’m sure you know my character 😂',
      isMe: true,
    ),
  ];

  final TextEditingController _messageController = TextEditingController();
  // 标志输入框是否为空
  bool _isInputEmpty = true;
  // 标志是否正在录音
  bool _isRecording = false;
  // 标志是否取消发送（上滑手势）
  bool _isRecordingCanceled = false;

  @override
  void initState() {
    super.initState();
    // 添加监听器以检测文本输入变化
    _messageController.addListener(_onMessageTextChanged);
  }

  @override
  void dispose() {
    // 移除监听器并释放控制器
    _messageController.removeListener(_onMessageTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _onMessageTextChanged() {
    // 根据文本内容更新 _isInputEmpty 状态
    setState(() {
      _isInputEmpty = _messageController.text.isEmpty;
    });
  }

  // 处理文本消息发送
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

  // 处理语音消息逻辑（此处为模拟）
  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
      _isRecordingCanceled = false;
    });
    print('开始录音...');
    // TODO: 实现实际的录音逻辑
  }

  void _onVoiceRecordingMove(LongPressMoveUpdateDetails details) {
    // 如果手指上滑超过一定距离，则取消录音
    // 这里的 80.0 是一个示例阈值，可以根据UI和用户体验调整
    if (details.localPosition.dy < -80.0) {
      if (!_isRecordingCanceled) {
        setState(() {
          _isRecordingCanceled = true;
        });
        print('上滑取消发送语音');
        // TODO: 停止录音并放弃录音文件
      }
    } else {
      // 如果从取消区域滑回，则恢复
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
      // TODO: 停止录音并发送语音文件
      // 模拟添加一条语音消息
      _messages.add(
        ChatMessage(
          sender: 'You',
          senderAvatar: 'https://picsum.photos/200/200?random=1000',
          text: '[语音消息] - (时长: 10s)', // 模拟语音消息文本
          isMe: true,
        ),
      );
    } else {
      print('语音发送已取消');
    }
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
              onPressed: () {
                context.router.pushNamed('/videocall');
              }),
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) => [
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
                  alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isMe ? Colors.pinkAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!message.isMe) // 对方消息显示对方头像
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
                        if (message.isMe) // 自己消息显示自己头像
                          const SizedBox(width: 8),
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
                    onChanged: (text) {
                      // 监听器的职责，这里无需额外处理，因为 _onMessageTextChanged 已经处理了
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    // TODO: 图片/视频发送功能
                  },
                ),
                // 根据输入框内容动态显示发送或语音按钮
                _isInputEmpty
                    ? GestureDetector(
                        onLongPressStart: (_) => _startVoiceRecording(),
                        onLongPressMoveUpdate: _onVoiceRecordingMove,
                        onLongPressEnd: (_) => _endVoiceRecording(),
                        child: Container(
                          // 可以添加一些视觉反馈，比如录音时改变背景色
                          decoration: BoxDecoration(
                            color: _isRecording && !_isRecordingCanceled
                                ? Colors.red.withOpacity(0.5)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.mic,
                            color: _isRecordingCanceled ? Colors.grey : Colors.pink,
                            size: 28, // 稍微大一点，更显眼
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