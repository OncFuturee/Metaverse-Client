import 'package:flutter/material.dart';


class LoginViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isSuccess = false;
  String errorMsg = '';
  bool isSmsSending = false;

  Future<void> loginWithPassword(String account, String password) async {
    isLoading = true;
    errorMsg = '';
    isSuccess = false;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    if (account == 'test' && password == '123456') {
      isSuccess = true;
    } else {
      errorMsg = '账号或密码错误';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> sendSms(String phone) async {
    isSmsSending = true;
    errorMsg = '';
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    if (phone.length == 11) {
      // 假设发送成功
    } else {
      errorMsg = '请输入正确的手机号';
    }
    isSmsSending = false;
    notifyListeners();
  }

  Future<void> loginWithSms(String phone, String smsCode) async {
    isLoading = true;
    errorMsg = '';
    isSuccess = false;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    if (phone.length == 11 && smsCode == '8888') {
      isSuccess = true;
    } else {
      errorMsg = '验证码错误';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithThirdParty(String type) async {
    isLoading = true;
    errorMsg = '';
    isSuccess = false;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    if (type == 'qq' || type == 'wechat' || type == 'weibo') {
      isSuccess = true;
    } else {
      errorMsg = '第三方登录失败';
    }
    isLoading = false;
    notifyListeners();
  }
}
