import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import './models/websocket_message.dart';
import 'message_bus.dart';

/// WebSocket连接状态
enum WebSocketStatus {
  disconnected,  // 未连接
  connecting,    // 连接中
  connected,     // 已连接
  error,         // 错误
}

/// WebSocket管理器，负责处理连接和消息收发
class WebSocketManager {
  /// 单例实例
  static final WebSocketManager _instance = WebSocketManager._internal();
  
  /// WebSocket通道
  WebSocketChannel? _channel;
  
  /// 连接状态
  WebSocketStatus _status = WebSocketStatus.disconnected;
  
  /// 重连计时器
  Timer? _reconnectTimer;
  
  /// 服务器地址
  String? _serverUrl;
  
  /// 重连间隔（毫秒）
  final int _reconnectInterval = 5000;
  
  /// 消息总线
  final MessageBus _messageBus = MessageBus();
  
  /// 连接状态流控制器
  final StreamController<WebSocketStatus> _statusController = StreamController<WebSocketStatus>.broadcast();
  
  /// 工厂构造函数，返回单例
  factory WebSocketManager() {
    return _instance;
  }
  
  /// 内部构造函数
  WebSocketManager._internal();
  
  /// 获取当前连接状态
  WebSocketStatus get status => _status;
  
  /// 获取连接状态流
  Stream<WebSocketStatus> get statusStream => _statusController.stream;
  
  /// 连接到服务器
  Future<void> connect(String url) async {
    // 如果正在连接或已连接，则返回
    if (_status == WebSocketStatus.connecting || _status == WebSocketStatus.connected) {
      return;
    }
    
    _serverUrl = url;
    _setStatus(WebSocketStatus.connecting);
    
    try {
      // 建立WebSocket连接，兼容web和原生
      if (kIsWeb) {
        _channel = WebSocketChannel.connect(Uri.parse(url));
      } else {
        _channel = IOWebSocketChannel.connect(url);
      }
      
      // 监听消息
      _channel?.stream.listen(
        _onMessageReceived,
        onError: _onError,
        onDone: _onDisconnected,
        cancelOnError: false,
      );
      
      _setStatus(WebSocketStatus.connected);
      _cancelReconnect();
    } catch (e) {
      _setStatus(WebSocketStatus.error);
      _scheduleReconnect();
      rethrow;
    }
  }
  
  /// 断开连接
  void disconnect({bool manual = true}) {
    _cancelReconnect();
    _channel?.sink.close();
    _channel = null;
    _setStatus(WebSocketStatus.disconnected);
  }
  
  /// 发送消息
  void sendMessage(WebSocketMessage message) {
    if (_status == WebSocketStatus.connected && _channel != null) {
      try {
        _channel?.sink.add(json.encode(message.toJson()));
      } catch (e) {
        _onError(e);
      }
    } else {
      throw Exception('WebSocket is not connected');
    }
  }
  
  /// 处理接收到的消息
  void _onMessageReceived(dynamic message) {
    try {
      // 解析JSON消息
      Map<String, dynamic> jsonMessage = json.decode(message.toString());
      WebSocketMessage webSocketMessage = WebSocketMessage.fromJson(jsonMessage);
      
      // 广播消息
      _messageBus.broadcast(webSocketMessage);
    } catch (e) {
      // 处理解析错误
      _messageBus.broadcast(
        WebSocketMessage(
          type: 'error',
          data: {'message': 'Failed to parse message', 'error': e.toString()},
        ),
      );
    }
  }
  
  /// 处理错误
  void _onError(dynamic error) {
    _setStatus(WebSocketStatus.error);
    _messageBus.broadcast(
      WebSocketMessage(
        type: 'connection_error',
        data: {'message': error.toString()},
      ),
    );
    _scheduleReconnect();
  }
  
  /// 处理断开连接
  void _onDisconnected() {
    if (_status != WebSocketStatus.disconnected) {
      _setStatus(WebSocketStatus.disconnected);
      _messageBus.broadcast(
        WebSocketMessage(
          type: 'disconnected',
          data: {'message': 'Connection lost'},
        ),
      );
      _scheduleReconnect();
    }
  }
  
  /// 设置连接状态
  void _setStatus(WebSocketStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
    }
  }
  
  /// 安排重连
  void _scheduleReconnect() {
    if (_serverUrl != null && (_reconnectTimer == null || !_reconnectTimer!.isActive)) {
      _reconnectTimer = Timer(Duration(milliseconds: _reconnectInterval), () {
        if (_status != WebSocketStatus.connected) {
          connect(_serverUrl!);
        }
      });
    }
  }
  
  /// 取消重连
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
  
  /// 释放资源
  void dispose() {
    disconnect();
    _statusController.close();
    _messageBus.dispose();
  }
}
