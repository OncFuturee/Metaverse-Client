import 'dart:async';
import './models/websocket_message.dart';
import 'websocket_manager.dart';
import 'message_bus.dart';

/// WebSocket服务类，提供对外的API接口
class WebSocketService {
  /// WebSocket管理器实例
  final WebSocketManager _manager = WebSocketManager();
  
  /// 消息总线实例
  final MessageBus _messageBus = MessageBus();
  
  /// 单例实例
  static final WebSocketService _instance = WebSocketService._internal();
  
  /// 工厂构造函数，返回单例
  factory WebSocketService() {
    return _instance;
  }
  
  /// 内部构造函数
  WebSocketService._internal() {
    _manager.statusStream.listen((status) {
      for (var listener in _statusListeners) {
        listener(status);
      }
    });
  }
  
  /// 连接状态回调列表
  final List<void Function(WebSocketStatus)> _statusListeners = [];

  /// 添加连接状态回调,WebSocket连接状态变化时会调用此回调
  /// @param listener 连接状态变化时的回调函数
  /// @return void
  void addStatusListener(void Function(WebSocketStatus) listener) {
    _statusListeners.add(listener);
  }

  /// 移除连接状态回调
  void removeStatusListener(void Function(WebSocketStatus) listener) {
    _statusListeners.remove(listener);
  }
  
  /// 获取当前连接状态
  WebSocketStatus get status => _manager.status;
  
  /// 获取连接状态流
  Stream<WebSocketStatus> get statusStream => _manager.statusStream;
  
  /// 连接到WebSocket服务器
  Future<void> connect(String url) => _manager.connect(url);
  
  /// 断开连接
  void disconnect() => _manager.disconnect();
  
  /// 发送消息到服务器
  void sendMessage(String type, dynamic data) {
    final message = WebSocketMessage(type: type, data: data);
    _manager.sendMessage(message);
  }
  
  /// 订阅特定类型的消息
  Stream<WebSocketMessage> subscribe(String messageType) {
    return _messageBus.on(messageType);
  }
  
  /// 订阅所有消息
  Stream<WebSocketMessage> subscribeToAll() {
    return _messageBus.onAll();
  }
  
  /// 释放资源
  void dispose() => _manager.dispose();
}
