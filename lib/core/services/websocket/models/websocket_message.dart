/// WebSocket消息模型类
class WebSocketMessage {
  /// 消息类型
  final String type;
  
  /// 消息内容
  final dynamic data;
  
  /// 消息发送时间
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 从JSON构建消息对象
  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String,
      data: json['data'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'WebSocketMessage{type: $type, data: $data, timestamp: $timestamp}';
  }
}
