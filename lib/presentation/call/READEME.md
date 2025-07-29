# 视频通话功能 API 文档

## 通信数据模型
所有消息通过 WebSocket 发送，消息结构如下：

```json
{
  "type": "video_call", // 示例为视频通话类型
  "data": {
    // 其它字段见下方
  }
}
```

## 信令类型及字段说明

### 1. 发起呼叫
- 客户端 → 服务端
```json
{
  "type": "video_call",
  "data": {
    "type": "call_request",
    "caller_userid": "username1",
    "callee_userid": "username2"
  }
}
```
- 服务端响应（转发给被叫）
```json
{
  "type": "video_call",
  "data": {
    "type": "call_request",
    "caller_userid": "username1",
    "callee_userid": "username2"
  }
}
```

### 2. 接听/拒绝/无人接听
- 客户端 → 服务端
```json
{
  "type": "video_call",
  "data": {
    "type": "call_accept", // 或 call_reject, no_answer
    "caller_userid": "username1",
    "callee_userid": "username2"
  }
}
```
- 服务端响应（转发给主叫）
```json
{
  "type": "video_call",
  "data": {
    "type": "call_accept", // 或 call_reject, no_answer
    "caller_userid": "username1",
    "callee_userid": "username2"
  }
}
```

### 3. 通话结束
- 客户端 → 服务端
```json
{
  "type": "video_call",
  "data": {
    "type": "call_end",
    "caller_userid": "username1",
    "callee_userid": "username2"
  }
}
```
- 服务端响应（转发给对方）
```json
{
  "type": "video_call",
  "data": {
    "type": "call_end",
    "caller_userid": "username1",
    "callee_userid": "username2"
  }
}
```

### 4. WebRTC 信令交换
#### 4.1 发送 Offer
- 客户端 → 服务端
```json
{
  "type": "video_call",
  "data": {
    "type": "rtc_offer",
    "caller_userid": "username1",
    "callee_userid": "username2",
    "sdp": "...",
    "sdp_type": "offer"
  }
}
```
- 服务端响应（转发给对方）同上

#### 4.2 发送 Answer
- 客户端 → 服务端
```json
{
  "type": "video_call",
  "data": {
    "type": "rtc_answer",
    "caller_userid": "username1",
    "callee_userid": "username2",
    "sdp": "...",
    "sdp_type": "answer"
  }
}
```
- 服务端响应（转发给对方）同上

#### 4.3 发送 ICE Candidate
- 客户端 → 服务端
```json
{
  "type": "video_call",
  "data": {
    "type": "rtc_ice_candidate",
    "caller_userid": "username1",
    "callee_userid": "username2",
    "candidate": {
      "candidate": "...",
      "sdpMid": "...",
      "sdpMLineIndex": 0
    }
  }
}
```
- 服务端响应（转发给对方）同上

#### 4.4 发送 Handled Answer
- 客户端 → 服务端
```json
{
  "type": "video_call",
  "data": {
    "type": "handled_answer",
    "caller_userid": "username1",
    "callee_userid": "username2"
  }
}
```

## 其它说明
- 所有信令消息都通过 WebSocket 发送和接收。
- 服务端需根据 caller_userid/callee_userid 字段进行消息路由。
- 客户端收到消息后根据 data.type 字段进行业务处理。

---
如需扩展其它信令类型，建议保持 type 字段风格一致。

## WebRTC 的信令流程通常是：

呼叫方 创建 Offer (createOffer)。

呼叫方 设置本地描述 (setLocalDescription)。

呼叫方 将 Offer 通过信令服务器发送给接听方。

接听方 收到 Offer 后，设置远程描述 (setRemoteDescription)。

接听方 创建 Answer (createAnswer)。

接听方 设置本地描述 (setLocalDescription)。

接听方 将 Answer 通过信令服务器发送给呼叫方。

呼叫方 收到 Answer 后，设置远程描述 (setRemoteDescription)。

双方 在设置完本地和远程描述后，开始交换 ICE 候选者。