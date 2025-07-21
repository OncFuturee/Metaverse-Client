import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

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
          IconButton(icon: const Icon(Icons.video_call), onPressed: () {context.router.pushNamed('/videocall');}),
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.pink),
                  onPressed: () {
                    // 发送消息逻辑，这里简单演示添加到列表
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
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 聊天消息数据模型
class ChatMessage {
  final String sender;
  final String senderAvatar;
  final String text;
  final bool isMe;

  ChatMessage({
    required this.sender,
    required this.senderAvatar,
    required this.text,
    required this.isMe,
  });
}
