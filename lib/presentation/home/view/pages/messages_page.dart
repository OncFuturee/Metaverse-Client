import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:metaverse_client/presentation/messages/view_models/chat_contact_model.dart';


class MessagesPage extends StatelessWidget {
  // 模拟数据，实际可从网络或数据库获取
  final List<ChatContact> _recentContacts = [
    ChatContact(
      name: 'Aubrey',
      message: '',
      time: '',
      avatarUrl: 'https://picsum.photos/200/200?random=1234',
    ),
    ChatContact(
      name: 'Darrell',
      message: '',
      time: '',
      avatarUrl: 'https://picsum.photos/200/200?random=2222',
    ),
    ChatContact(
      name: 'Julie',
      message: '',
      time: '',
      avatarUrl: 'https://picsum.photos/200/200?random=6666',
    ),
    ChatContact(
      name: 'Kristin',
      message: '',
      time: '',
      avatarUrl: 'https://picsum.photos/200/200?random=6668',
    ),
  ];

  final List<ChatContact> _messageContacts = [
    ChatContact(
      name: 'Theresa Varnes',
      message: 'Hi, morning too Andrew!',
      time: '10:00',
      avatarUrl: 'https://picsum.photos/200/200?random=6666',
      unreadCount: 1,
    ),
    ChatContact(
      name: 'Rayford Chenail',
      message: 'perfect! 💯💯',
      time: '09:44',
      avatarUrl: 'https://picsum.photos/200/200?random=6666',
      unreadCount: 2,
    ),
    ChatContact(
      name: 'Pedro Huard',
      message: 'Haha that\'s terrifying 😂',
      time: '09:26',
      avatarUrl: 'https://picsum.photos/200/200?random=6666',
    ),
    ChatContact(
      name: 'Leatrice Handler',
      message: 'How are you? 😊😊',
      time: 'Yesterday',
      avatarUrl: 'https://picsum.photos/200/200?random=6666',
      unreadCount: 3,
    ),
    ChatContact(
      name: 'Kristin Watson',
      message: 'just ideas for next time 😊',
      time: 'Dec 18, 2024',
      avatarUrl: 'https://picsum.photos/200/200?random=6666',
    ),
    ChatContact(
      name: 'Rochel Foose',
      message: 'Haha oh man 😂😂😂',
      time: 'Dec 17, 2024',
      avatarUrl: 'https://picsum.photos/200/200?random=6666',
    ),
  ];

  MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.pop(), // 返回上一页
        ),
        title: const Text('Messages'), // 页面标题
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}), // 添加按钮
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'more',
                    child: Text('More'),
                  ), // 更多选项
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 搜索栏
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search', // 搜索提示
                  prefixIcon: const Icon(Icons.search), // 搜索图标
                  suffixIcon: const Icon(Icons.tune), // 筛选图标
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // 圆角边框
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 最近联系人区域标题
              const Text(
                'Recently',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // 最近联系人列表
              SizedBox(
                height: 80, // 固定高度，用于水平滚动
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // 水平滚动
                  itemCount: _recentContacts.length, // 最近联系人数量
                  itemBuilder: (context, index) {
                    final contact = _recentContacts[index];
                    return GestureDetector(
                      onTap: () {
                        // **点击最近联系人时，导航到聊天详情页**
                        context.router.pushNamed('/chat');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                contact.avatarUrl,
                              ), // 联系人头像
                              radius: 28, // 头像半径
                            ),
                            const SizedBox(height: 4),
                            Text(contact.name), // 联系人姓名
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // 消息列表区域标题
              const Text(
                'Messages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // 消息列表
              ListView.builder(
                shrinkWrap: true, // 根据内容调整高度
                physics:
                    const NeverScrollableScrollPhysics(), // 禁用内部滚动，让SingleChildScrollView处理
                itemCount: _messageContacts.length, // 消息联系人数量
                itemBuilder: (context, index) {
                  final contact = _messageContacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        contact.avatarUrl,
                      ), // 消息联系人头像
                    ),
                    title: Text(contact.name), // 消息联系人姓名
                    subtitle: Text(contact.message), // 最新消息内容
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          contact.time, // 消息时间
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (contact.unreadCount > 0) // 如果有未读消息
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink, // 未读消息背景颜色
                              borderRadius: BorderRadius.circular(12), // 圆角
                            ),
                            child: Text(
                              contact.unreadCount.toString(), // 未读消息数量
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      // **点击消息项时，导航到聊天详情页**
                      context.router.pushNamed('/chat');
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
