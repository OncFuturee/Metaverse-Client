import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/login_viewmodel.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  int _loginType = 0; // 0:账号密码 1:短信 2:第三方
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();

  late AnimationController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildLoginForm(LoginViewModel vm) {
    switch (_loginType) {
      case 0:
        return FadeTransition(
          opacity: _tabController,
          child: Column(
            children: [
              TextField(
                controller: _accountController,
                decoration: const InputDecoration(labelText: '账号'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '密码'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        await vm.loginWithPassword(_accountController.text, _passwordController.text);
                        if (vm.isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('登录成功')));
                        } else if (vm.errorMsg.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMsg)));
                        }
                      },
                child: vm.isLoading ? const CircularProgressIndicator() : const Text('账号密码登录'),
              ),
            ],
          ),
        );
      case 1:
        return FadeTransition(
          opacity: _tabController,
          child: Column(
            children: [
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: '手机号'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _smsController,
                      decoration: const InputDecoration(labelText: '验证码'),
                    ),
                  ),
                  TextButton(
                    onPressed: vm.isSmsSending
                        ? null
                        : () async {
                            await vm.sendSms(_phoneController.text);
                            if (vm.errorMsg.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMsg)));
                            }
                          },
                    child: vm.isSmsSending ? const CircularProgressIndicator() : const Text('获取验证码'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        await vm.loginWithSms(_phoneController.text, _smsController.text);
                        if (vm.isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('登录成功')));
                        } else if (vm.errorMsg.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMsg)));
                        }
                      },
                child: vm.isLoading ? const CircularProgressIndicator() : const Text('短信验证码登录'),
              ),
            ],
          ),
        );
      case 2:
        return FadeTransition(
          opacity: _tabController,
          child: Column(
            children: [
              const Text('第三方账号登录', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset('assets/qq.png', width: 40),
                    onPressed: () async {
                      await vm.loginWithThirdParty('qq');
                      if (vm.isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QQ登录成功')));
                      } else if (vm.errorMsg.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMsg)));
                      }
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/wechat.png', width: 40),
                    onPressed: () async {
                      await vm.loginWithThirdParty('wechat');
                      if (vm.isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('微信登录成功')));
                      } else if (vm.errorMsg.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMsg)));
                      }
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/weibo.png', width: 40),
                    onPressed: () async {
                      await vm.loginWithThirdParty('weibo');
                      if (vm.isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('微博登录成功')));
                      } else if (vm.errorMsg.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMsg)));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('登录')),
            body: Center(
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Column(
                    key: ValueKey(_loginType),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ToggleButtons(
                        isSelected: [
                          _loginType == 0,
                          _loginType == 1,
                          _loginType == 2,
                        ],
                        borderRadius: BorderRadius.circular(8),
                        onPressed: (index) {
                          setState(() {
                            _loginType = index;
                            _tabController.forward(from: 0);
                          });
                        },
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('账号密码'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('短信登录'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('第三方'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        child: _buildLoginForm(vm),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}