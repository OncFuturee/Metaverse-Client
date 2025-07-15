import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // 为每个 TextField 定义 FocusNode
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  // 定义颜色
  final Color _focusedColor = const Color(0xFFff4d67); // 你的主题色，即登录按钮的颜色
  // _focusedColor 的淡一点的版本，这里使用了 0x1A 作为透明度（大约 10%）
  final Color _focusedFillColor = const Color(0x1Aff4d67);
  final Color _defaultFillColor = const Color(0xFFFAFAFA);
  final Color _defaultIconColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    // 添加监听器，当焦点改变时触发重绘
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    // 移除监听器并释放 FocusNode 资源，避免内存泄漏
    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // 焦点改变时调用此方法，触发 UI 更新
  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // 将整个 body 包裹在 GestureDetector 中
      body: GestureDetector(
        onTap: () {
          // 当点击非输入框区域时，移除当前焦点
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          // 滚动视图 SingleChildScrollView 以处理内容溢出
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // 标题
                const Text(
                  'Create your Account',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),

                // 邮箱输入框
                TextField(
                  focusNode: _emailFocusNode, // 绑定焦点节点
                  decoration: InputDecoration(
                    filled: true,
                    // 根据焦点状态改变填充颜色
                    fillColor:
                        _emailFocusNode.hasFocus
                            ? _focusedFillColor
                            : _defaultFillColor,
                    // 根据焦点状态改变图标颜色
                    prefixIcon: Icon(
                      Icons.email,
                      color:
                          _emailFocusNode.hasFocus
                              ? _focusedColor
                              : _defaultIconColor,
                    ),
                    hintText: 'Email',
                    // 默认边框
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            _emailFocusNode.hasFocus
                                ? _focusedColor
                                : Colors.transparent,
                      ),
                    ),
                    // 未启用时的边框
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            _emailFocusNode.hasFocus
                                ? _focusedColor
                                : Colors.transparent,
                      ),
                    ),
                    // 获取焦点时的边框
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            _emailFocusNode.hasFocus
                                ? _focusedColor
                                : Colors.transparent,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 密码输入框
                TextField(
                  focusNode: _passwordFocusNode, // 绑定焦点节点
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    filled: true,
                    // 根据焦点状态改变填充颜色
                    fillColor:
                        _passwordFocusNode.hasFocus
                            ? _focusedFillColor
                            : _defaultFillColor,
                    // 根据焦点状态改变图标颜色
                    prefixIcon: Icon(
                      Icons.lock,
                      color:
                          _passwordFocusNode.hasFocus
                              ? _focusedColor
                              : _defaultIconColor,
                    ),
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color:
                            _passwordFocusNode.hasFocus
                                ? _focusedColor
                                : _defaultIconColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    // 默认边框
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            _passwordFocusNode.hasFocus
                                ? _focusedColor
                                : Colors.transparent,
                      ),
                    ),
                    // 未启用时的边框
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            _passwordFocusNode.hasFocus
                                ? _focusedColor
                                : Colors.transparent,
                      ),
                    ),
                    // 获取焦点时的边框
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            _passwordFocusNode.hasFocus
                                ? _focusedColor
                                : Colors.transparent,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 记住我
                Row(
                  children: [
                    Checkbox(
                      activeColor: _focusedColor, // 复选框的激活颜色也与主题色保持一致
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    const Text('Remember me'),
                  ],
                ),

                const SizedBox(height: 24),

                // 注册按钮
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _focusedColor, // 登录按钮的颜色
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () {
                    // 处理注册逻辑
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 24),

                // 分隔线
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('or continue with'),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),

                const SizedBox(height: 24),

                // 第三方登录（使用图片）
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      imagePath: 'assets/icons/facebook.png', // 替换为实际图片路径
                      onTap: () {},
                    ),
                    _buildSocialButton(
                      imagePath: 'assets/icons/google.png', // 替换为实际图片路径
                      onTap: () {},
                    ),
                    _buildSocialButton(
                      imagePath: 'assets/icons/apple.png', // 替换为实际图片路径
                      onTap: () {},
                    ),
                    _buildSocialButton(
                      imagePath: 'assets/icons/phone.png', // 替换为实际图片路径
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 已有账号登录跳转
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        // 跳转到登录页，这里可根据实际路由调整
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建第三方登录按钮（使用图片）
  Widget _buildSocialButton({
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(child: Image.asset(imagePath, fit: BoxFit.contain)),
        ),
      ),
    );
  }
}
