import 'dart:async';
import './models/websocket_message.dart';

/// 消息总线，负责消息的广播和订阅
class MessageBus {
  /// 单例实例
  static final MessageBus _instance = MessageBus._internal();
  
  /// 消息流控制器
  final StreamController<WebSocketMessage> _messageController = StreamController<WebSocketMessage>.broadcast();
  
  /// 工厂构造函数，返回单例
  factory MessageBus() {
    return _instance;
  }
  
  /// 内部构造函数
  MessageBus._internal();
  
  /// 发送消息（广播）
  void broadcast(WebSocketMessage message) {
    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
  }
  
  /// 订阅特定类型的消息
  Stream<WebSocketMessage> on(String messageType) {
    return _messageController.stream.where((message) => message.type == messageType);
  }
  
  /// 订阅所有消息
  Stream<WebSocketMessage> onAll() {
    return _messageController.stream;
  }
  
  /// 关闭消息总线
  void dispose() {
    _messageController.close();
  }
}
