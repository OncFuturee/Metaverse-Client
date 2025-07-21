
/// 聊天联系人数据模型
class ChatContact {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final int unreadCount;

  ChatContact({
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    this.unreadCount = 0,
  });
}
