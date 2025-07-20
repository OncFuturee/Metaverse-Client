import 'package:flutter/material.dart';
import 'dart:async';

/// CustomTapDetector 是一个自定义的手势检测器，用于处理单击和双击事件。
/// 它允许开发者定义单击和双击的回调函数，并且可以自定义双击的时间间隔。
class CustomTapDetector extends StatefulWidget {
  final VoidCallback onSingleTap;
  final VoidCallback onDoubleTap;
  final Widget child;
  final Duration doubleTapInterval; // 可自定义的双击间隔

  const CustomTapDetector({
    super.key,
    required this.onSingleTap,
    required this.onDoubleTap,
    required this.child,
    this.doubleTapInterval = const Duration(milliseconds: 250), // 默认为 250ms
  });

  /// 设置双击间隔，必须大于等于 50 毫秒
  set doubleTapInterval(Duration interval) {
    if (interval.inMilliseconds < 50) {
      throw ArgumentError('双击间隔不能小于 50 毫秒');
    }
    // 更新双击间隔
    doubleTapInterval = interval;
  }

  @override
  _CustomTapDetectorState createState() => _CustomTapDetectorState();
}

class _CustomTapDetectorState extends State<CustomTapDetector> {
  DateTime? _lastTapTime;
  Timer? _singleTapTimer;

  void _handleTap() {
    final now = DateTime.now();

    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > widget.doubleTapInterval) {
      // 第一次点击，或距离上次点击超过了双击间隔，可能是一个单击
      _lastTapTime = now;
      _singleTapTimer = Timer(widget.doubleTapInterval, () {
        // 如果在间隔时间内没有第二次点击，则认为是单击
        widget.onSingleTap();
        _lastTapTime = null; // 重置，为下一次点击序列做准备
      });
    } else {
      // 在双击间隔时间内发生了第二次点击，所以是双击
      _singleTapTimer?.cancel(); // 取消待定的单击操作
      widget.onDoubleTap();
      _lastTapTime = null; // 重置，为下一次点击序列做准备
    }
  }

  @override
  void dispose() {
    _singleTapTimer?.cancel(); // 在 Widget 销毁时取消定时器，防止内存泄漏
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _handleTap, child: widget.child);
  }
}