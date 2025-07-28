// websocket/call_notification_manager.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
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

  // 新增：用来存储UI层传入的BuildContext，但更推荐每次调用时传入
  // 注意：不建议直接保存BuildContext，因为它可能变得无效。
  // 更好的方式是每次需要显示时，由UI层提供。
  BuildContext? _uiContextForOverlay;

  // 提供一个方法让UI层设置当前的BuildContext
  void setContextForOverlay(BuildContext context) {
    _uiContextForOverlay = context;
  }

  // 在不再需要时清除context
  void clearContextForOverlay() {
    _uiContextForOverlay = null;
  }

  // 处理来电通知
  void _handleIncomingCall(WebSocketMessage message) {
    final data = message.data as Map<String, dynamic>?;
    if (data == null) return;
    // 只处理 type 为 call_request 的来电
    if (data['type'] == 'call_request' && data['caller_userid'] != null && data['callee_userid'] != null) {
      _callerId = data['caller_userid'];
      _remainingSeconds = 30;
      _callStateNotifier.value = CallState.incoming;
      // 检查是否有可用的BuildContext
      if (_uiContextForOverlay != null) {
        _showCallNotification(_uiContextForOverlay!); // 传入Context
      } else {
        debugPrint('错误： 没有可用的 UI 上下文来显示call notification overlay.');
        // 可以在这里触发一个本地通知，作为备用方案
      }
      _startCountdown();
    }
  }

  // 显示来电通知弹窗
  void _showCallNotification(BuildContext context) { 
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder:
          (overlayContext) => CallNotificationOverlay( // 注意这里是 overlayContext
            callerId: _callerId ?? '未知用户',
            remainingSeconds: _remainingSeconds,
            onAnswer: (ctx) { // onAnswer 接收的 context 是 OverlayEntry 内部的 context
              _answerCall(ctx); // 将 OverlayEntry 内部的 context 传递给 _answerCall
            },
            onReject: _rejectCall,
            countdownNotifier: ValueNotifier(_remainingSeconds), // 考虑使用外部共享的ValueNotifier
          ),
    );

    // 使用传入的context插入弹窗
    try {
      debugPrint("插入弹窗。");
      Overlay.of(context).insert(_overlayEntry!);
    } catch (e) {
      debugPrint('插入 OverlayEntry 时出错: $e');
      _overlayEntry = null; // 插入失败则清除
    }
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
    // 通知服务器已接听
    // 由于通话界面需要对webrtc进行初始化，此时客户端还没有准备好
    // 接听电话，所以将通知服务器已接听的逻辑放在视频通话界面中处理
    // 这里可以直接导航到视频通话界面

    // 导航到视频通话界面（作为接听方）
    context.pushRoute(VideoCallRoute(userId: _callerId, isCaller: false));

    _cleanup();
  }

  // 挂断电话
  void _rejectCall() {
    _sendCallResponse('rejected');
    _cleanup();
  }

  // 自动挂断（无应答）
  void _autoRejectCall() {
    _sendCallResponse('no_answer');
    _cleanup();
  }

  // 发送通话响应到服务器
  void _sendCallResponse(String status) {
    // status: accepted/rejected/no_answer
    WebSocketService().sendMessage('video_call', {
      'type': status == 'rejected' ? 'call_reject' : 'no_answer',
      'caller_userid': _callerId,
      'callee_userid': DebugConfig.instance.params['userId'],
    });
  }

  // 清理资源
  void _cleanup() {
    _countdownTimer?.cancel();
    // 确保在 dispose 或 cleanup 时移除OverlayEntry
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.remove();
    }
    _overlayEntry = null;
    _callerId = null;
    _callStateNotifier.value = CallState.idle;
    // 不在这里清除_uiContextForOverlay，因为它可能在整个应用生命周期中有效
  }

  // 主动关闭弹窗（如应用退出时），并清理context
  void dispose() {
    _cleanup();
    clearContextForOverlay(); // 在应用生命周期结束时清理
  }
}

/// 通话状态枚举
enum CallState {
  idle, // 空闲
  incoming, // 来电中
  counting, // 倒计时中
}

