import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDrawerPage extends StatefulWidget {
  final VoidCallback onClose;
  const ProfileDrawerPage({super.key, required this.onClose});

  @override
  State<ProfileDrawerPage> createState() => _ProfileDrawerPageState();
}

class _ProfileDrawerPageState extends State<ProfileDrawerPage> {
  final TextEditingController _jsonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _loadJsonData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('debug_params') ?? '{}';
    _jsonController.text = _formatJson(jsonData);
  }

  Future<void> _saveJsonData() async {
    try {
      // 尝试解析JSON以验证格式
      final jsonObject = json.decode(_jsonController.text);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('debug_params', json.encode(jsonObject));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('JSON数据已保存！')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败：无效的JSON格式。错误：$e')));
    }
  }

  String _formatJson(String jsonString) {
    try {
      final jsonObject = json.decode(jsonString);
      return const JsonEncoder.withIndent('  ').convert(jsonObject);
    } catch (e) {
      return jsonString; // 如果格式无效，返回原始字符串
    }
  }

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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/seed/100/200/200',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('昵称：示例用户', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text('签名：这个人很懒，什么都没有写。'),

                      // ...可扩展更多信息...
                      const SizedBox(height: 40),
                      // --- 调试面板 ---
                      const Divider(),
                      const Text(
                        '调试面板',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _jsonController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            hintText: '在这里输入JSON数据...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveJsonData,
                          child: const Text('保存'),
                        ),
                      ),
                      const SizedBox(height: 40), // 留出底部空间
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
