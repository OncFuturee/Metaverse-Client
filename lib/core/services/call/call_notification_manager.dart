// websocket/call_notification_manager.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:metaverse_client/core/config/debug_config.dart';
import '../websocket/websocket_service.dart';
import '../websocket/models/websocket_message.dart';
import 'package:metaverse_client/routes/app_router.dart';

import 'package:metaverse_client/presentation/call/view/widgets/call_notification_overlay.dart';

/// 来电状态管理单例
class CallNotificationManager {
  // 单例实例
  static final CallNotificationManager _instance = CallNotificationManager._internal();
  factory CallNotificationManager() => _instance;
  CallNotificationManager._internal() {
    _initWebSocketListener();
  }

  // 状态变量
  bool _hasIncomingCall = false;
  String? _callerId;
  Timer? _countdownTimer;
  int _remainingSeconds = 30;
  OverlayEntry? _overlayEntry;
  final ValueNotifier<CallState> _callStateNotifier = ValueNotifier(
    CallState.idle,
  );

  // 对外暴露的状态流
  ValueNotifier<CallState> get callStateNotifier => _callStateNotifier;
  int get remainingSeconds => _remainingSeconds;

  // 初始化WebSocket监听
  void _initWebSocketListener() {
    // 只订阅 video_call 类型消息
    WebSocketService().subscribe('video_call').listen((message) {
      _handleIncomingCall(message);
    });
  }

  // 处理来电通知
  void _handleIncomingCall(WebSocketMessage message) {
    final data = message.data as Map<String, dynamic>?;
    if (data == null) return;
    // 只处理 type 为 call_request 的来电
    if (data['type'] == 'call_request' && data['caller_userid'] != null && data['callee_userid'] != null) {
      _callerId = data['caller_userid'];
      _hasIncomingCall = true;
      _remainingSeconds = 30;
      _callStateNotifier.value = CallState.incoming;
      _showCallNotification();
      _startCountdown();
    }
  }

  // 显示来电通知弹窗
  void _showCallNotification() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => CallNotificationOverlay(
            callerId: _callerId ?? '未知用户',
            remainingSeconds: _remainingSeconds,
            onAnswer: _answerCall,
            onReject: _rejectCall,
            countdownNotifier: ValueNotifier(_remainingSeconds),
          ),
    );

    // 获取根Overlay并插入弹窗
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(
        AppRouter.rootNavigatorKey.currentContext!,
      );
      overlay?.insert(_overlayEntry!);
    });
  }

  // 开始30秒倒计时
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        _autoRejectCall();
        timer.cancel();
        return;
      }
      _remainingSeconds--;
      _callStateNotifier.value = CallState.counting;
    });
  }

  // 接听电话
  void _answerCall(BuildContext context) {
    _cleanup();
    // 通知服务器已接听
    _sendCallResponse('accepted');
    // 导航到视频通话界面（作为接听方）
    context.pushRoute(VideoCallRoute(userId: _callerId, isCaller: false));
  }

  // 挂断电话
  void _rejectCall() {
    _cleanup();
    _sendCallResponse('rejected');
  }

  // 自动挂断（无应答）
  void _autoRejectCall() {
    _cleanup();
    _sendCallResponse('no_answer');
  }

  // 发送通话响应到服务器
  void _sendCallResponse(String status) {
    // status: accepted/rejected/no_answer
    WebSocketService().sendMessage('video_call', {
      'type': status == 'accepted' ? 'call_accept' : (status == 'rejected' ? 'call_reject' : 'no_answer'),
      'caller_userid': _callerId,
      'callee_userid': DebugConfig.instance.params['userId'],
    });
  }

  // 清理资源
  void _cleanup() {
    _countdownTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _hasIncomingCall = false;
    _callerId = null;
    _callStateNotifier.value = CallState.idle;
  }

  // 主动关闭弹窗（如应用退出时）
  void dispose() {
    _cleanup();
  }
}

/// 通话状态枚举
enum CallState {
  idle, // 空闲
  incoming, // 来电中
  counting, // 倒计时中
}

