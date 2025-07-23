

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