// widgets/call_notification_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 来电通知悬浮组件
class CallNotificationOverlay extends StatefulWidget {
  final String callerId;
  final int remainingSeconds;
  final Function(BuildContext) onAnswer;
  final VoidCallback onReject;
  final ValueNotifier<int> countdownNotifier;

  const CallNotificationOverlay({
    super.key,
    required this.callerId,
    required this.remainingSeconds,
    required this.onAnswer,
    required this.onReject,
    required this.countdownNotifier,
  });

  @override
  State<CallNotificationOverlay> createState() =>
      _CallNotificationOverlayState();
}

class _CallNotificationOverlayState extends State<CallNotificationOverlay> {
  @override
  void initState() {
    super.initState();
    // 监听倒计时变化
    widget.countdownNotifier.addListener(_updateCountdown);
    // 锁定屏幕方向（可选）
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    widget.countdownNotifier.removeListener(_updateCountdown);
    // 恢复屏幕方向
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  void _updateCountdown() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 确保弹窗在最上层（通过Stack和z-index）
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // 半透明背景（可选，增强聚焦）
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // 阻止点击穿透
              child: Container(color: Colors.black38),
            ),
          ),
          // 顶部来电通知卡片
          Positioned(
            top: MediaQuery.of(context).padding.top, // 适配状态栏
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 来电提示
                  Text(
                    '来自 ${"widget.callerId"} 的视频通话',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 倒计时显示
                  Text(
                    '${widget.countdownNotifier.value}秒后自动挂断',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  // 操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 挂断按钮
                      FloatingActionButton(
                        heroTag: 'reject_call',
                        onPressed: widget.onReject,
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.call_end),
                      ),
                      // 接听按钮
                      FloatingActionButton(
                        heroTag: 'accept_call',
                        onPressed: () => widget.onAnswer(context),
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.call),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
