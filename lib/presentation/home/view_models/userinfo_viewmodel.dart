import 'package:flutter/material.dart';

// 假设有一个用户状态管理服务
class UserinfoViewmodel with ChangeNotifier {
  bool _isLoggedIn = false; // 初始状态为未登录

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}