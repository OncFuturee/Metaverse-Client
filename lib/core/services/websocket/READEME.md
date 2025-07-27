# WebSocket通信模块

一个功能完善、低耦合、高内聚的Flutter WebSocket通信模块，支持客户端与服务器的实时通信，并提供消息广播与订阅机制。

## 功能特性

- 建立和管理WebSocket连接
- 自动重连机制
- 消息的发送与接收
- 基于发布-订阅模式的消息广播
- 连接状态监听
- 单例模式确保全局唯一连接
- 完善的错误处理

## 模块结构

```
websocket/
├── models
|   └── websocket_message.dart# 消息模型定义
├── websocket_service.dart    # 对外API接口
├── websocket_manager.dart    # WebSocket连接管理
└── message_bus.dart          # 消息总线，处理消息订阅与广播

```

## 快速开始

### 1. 初始化与连接

```dart
// 连接到WebSocket服务器 单例模式
await WebSocketService().connect('wss://your-server-url.com');

// 监听连接状态
WebSocketService().statusStream.listen((status) {
  print('连接状态: $status');
  switch (status) {
    case WebSocketStatus.connecting:
      // 正在连接
      break;
    case WebSocketStatus.connected:
      // 连接成功
      break;
    case WebSocketStatus.disconnected:
      // 已断开连接
      break;
    case WebSocketStatus.error:
      // 连接错误
      break;
  }
});
```

### 2. 发送消息

```dart
// 发送消息到服务器
WebSocketService().sendMessage(
  'chat_message',  // 消息类型
  {               // 消息数据
    'username': '张三',
    'content': 'Hello, World!',
    'timestamp': DateTime.now().toIso8601String()
  }
);
```

### 3. 接收消息

```dart
// 订阅特定类型的消息
StreamSubscription? chatSubscription;

void initState() {
  super.initState();
  
  // 订阅聊天消息
  chatSubscription = WebSocketService()
      .subscribe('chat_message')
      .listen((message) {
    // 处理收到的消息
    print('收到聊天消息: ${message.data}');
    // 更新UI或进行其他业务逻辑处理
  });
  
  // 可选：订阅所有消息
  allMessageSubscription = WebSocketService()
      .subscribeToAll()
      .listen((message) {
    print('收到${message.type}类型消息: ${message.data}');
  });
}

// 页面销毁时取消订阅
@override
void dispose() {
  chatSubscription?.cancel();
  allMessageSubscription?.cancel();
  super.dispose();
}
```

### 4. 断开连接

```dart
// 主动断开连接
WebSocketService().disconnect();
```

## API 参考

### WebSocketService

WebSocket服务的主要接口类，采用单例模式。

| 方法 | 描述 |
|------|------|
| `connect(String url)` | 连接到指定的WebSocket服务器 |
| `disconnect()` | 断开当前连接 |
| `sendMessage(String type, dynamic data)` | 发送消息到服务器 |
| `subscribe(String messageType)` | 订阅特定类型的消息，返回消息流 |
| `subscribeToAll()` | 订阅所有类型的消息，返回消息流 |
| `dispose()` | 释放资源 |

| 属性 | 描述 |
|------|------|
| `status` | 当前连接状态 |
| `statusStream` | 连接状态变化的流 |

### WebSocketStatus

连接状态枚举：

- `connecting`：正在连接
- `connected`：已连接
- `disconnected`：已断开
- `error`：连接错误

### WebSocketMessage

消息模型类：

| 属性 | 描述 |
|------|------|
| `type` | 消息类型（字符串） |
| `data` | 消息内容（动态类型） |
| `timestamp` | 消息时间戳 |

## 注意事项

1. 确保在不需要使用WebSocket时及时断开连接，特别是在页面销毁时
2. 订阅消息后，务必在适当的时候取消订阅，避免内存泄漏
3. 处理网络异常情况，模块会自动尝试重连，但建议在UI上给予用户提示
4. 消息数据的序列化和反序列化需要与服务器端保持一致
5. 对于敏感信息，建议在发送前进行加密处理

## 扩展建议

1. 可以扩展消息模型，添加消息ID用于消息追踪
2. 可以添加消息缓存机制，在网络断开时缓存消息，连接恢复后发送
3. 可以添加认证机制，在建立连接后发送认证信息
4. 可以根据需要调整自动重连的策略和间隔时间

通过这个模块，你可以轻松实现Flutter应用与服务器的实时通信功能，并且保持代码的清晰结构和低耦合性。