import 'dart:math';

import 'package:flutter/material.dart';

class ProfileDrawerPage extends StatelessWidget {
  final VoidCallback onClose;
  const ProfileDrawerPage({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 1.0, // 占满全屏宽度
        child: Material(
          color: Theme.of(context).canvasColor,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 36, backgroundImage: NetworkImage('https://picsum.photos/seed/${Random().nextInt(1000)}/200/200')),
                    SizedBox(height: 16),
                    Text('昵称：示例用户', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('签名：这个人很懒，什么都没有写。'),
                    // ...可扩展更多信息...
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
