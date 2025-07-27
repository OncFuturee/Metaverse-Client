import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:metaverse_client/core/config/debug_config.dart';
import 'package:metaverse_client/core/services/websocket/models/websocket_message.dart';
import 'package:metaverse_client/core/services/websocket/websocket_manager.dart';
import 'package:metaverse_client/core/services/websocket/websocket_service.dart';

@RoutePage()
class VideoCallScreen extends StatefulWidget {
  final String? userId; // 通话目标用户ID
  final bool isCaller; // 是否是呼叫发起方

  const VideoCallScreen({
    super.key,
    @queryParam this.userId,
    @queryParam this.isCaller = false,
  });

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // WebRTC 相关
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  // WebSocket相关
  late WebSocketService _webSocketService;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionStatusSubscription;

  // 状态控制
  bool _isCameraOn = true;
  bool _isMicOn = true;
  bool _isSpeakerOn = true;
  bool _isConnecting = true;
  String _connectionStatus = "获取连接状态中...";
  bool _isWebSocketConnected = false;
  bool _isCallAccepted = false;
  bool _isCallEnded = false;

  String? _callerUserId;
  String? _calleeUserId;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    _webSocketService = WebSocketService();
    _setupWebSocketListener();
    _initWebRTC();
    // 业务身份区分
    if (widget.isCaller) {
      _callerUserId = DebugConfig.instance.params['userId'];
      _calleeUserId = widget.userId;
      _sendCallRequest();
    } else {
      _callerUserId = widget.userId;
      _calleeUserId = DebugConfig.instance.params['userId'];
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.close();
    _messageSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    if (!_isCallEnded) _sendCallEndMessage();
    super.dispose();
  }

  // WebSocket监听和信令处理
  void _setupWebSocketListener() {
    _connectionStatusSubscription = _webSocketService.statusStream.listen((status) {
      setState(() {
        switch (status) {
          case WebSocketStatus.connected:
            _isConnecting = false;
            _isWebSocketConnected = true;
            _connectionStatus = "已连接";
            break;
          case WebSocketStatus.connecting:
            _isConnecting = true;
            _isWebSocketConnected = false;
            _connectionStatus = "连接中...";
            break;
          case WebSocketStatus.disconnected:
            _isConnecting = false;
            _isWebSocketConnected = false;
            _connectionStatus = "已断开";
            _showReconnectDialog();
            break;
          case WebSocketStatus.error:
            _isConnecting = false;
            _isWebSocketConnected = false;
            _connectionStatus = "连接错误";
            _showReconnectDialog();
            break;
        }
      });
    });
    // 订阅 video_call 类型消息
    _messageSubscription = _webSocketService.subscribe('video_call').listen((message) {
      _handleSignalingMessage(message);
    });
  }

  // 发送呼叫请求
  void _sendCallRequest() {
    if (_callerUserId == null || _calleeUserId == null) return;
    _webSocketService.sendMessage('video_call', {
      'type': 'call_request',
      'caller_userid': _callerUserId,
      'callee_userid': _calleeUserId,
    });
  }

  // 发送接听/拒绝/结束等信令
  void _sendCallAccept() {
    _webSocketService.sendMessage('video_call', {
      'type': 'call_accept',
      'caller_userid': _callerUserId,
      'callee_userid': _calleeUserId,
    });
  }
  void _sendCallReject() {
    _webSocketService.sendMessage('video_call', {
      'type': 'call_reject',
      'caller_userid': _callerUserId,
      'callee_userid': _calleeUserId,
    });
  }
  void _sendCallEndMessage() {
    _isCallEnded = true;
    _webSocketService.sendMessage('video_call', {
      'type': 'call_end',
      'caller_userid': _callerUserId,
      'callee_userid': _calleeUserId,
    });
  }

  // 发送WebRTC信令
  void _sendRtcOffer(String sdp, String type) {
    _webSocketService.sendMessage('video_call', {
      'type': 'rtc_offer',
      'caller_userid': _callerUserId,
      'callee_userid': _calleeUserId,
      'sdp': sdp,
      'sdp_type': type,
    });
  }
  void _sendRtcAnswer(String sdp, String type) {
    _webSocketService.sendMessage('video_call', {
      'type': 'rtc_answer',
      'caller_userid': _callerUserId,
      'callee_userid': _calleeUserId,
      'sdp': sdp,
      'sdp_type': type,
    });
  }
  void _sendRtcIceCandidate(Map<String, dynamic> candidate) {
    _webSocketService.sendMessage('video_call', {
      'type': 'rtc_ice_candidate',
      'caller_userid': _callerUserId,
      'callee_userid': _calleeUserId,
      'candidate': candidate,
    });
  }

  // 信令消息处理
  void _handleSignalingMessage(WebSocketMessage message) {
    final data = message.data as Map<String, dynamic>?;
    if (data == null) return;
    // 只处理与本通话相关的消息
    if (data['caller_userid'] != _callerUserId || data['callee_userid'] != _calleeUserId) return;
    switch (data['type']) {
      case 'call_accept':
        if (widget.isCaller) {
          setState(() { _isCallAccepted = true; });
          _createAndSendOffer();
        }
        break;
      case 'call_reject':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('对方已拒绝通话')));
        _endCall();
        break;
      case 'call_end':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('通话已结束')));
        _endCall();
        break;
      case 'rtc_offer':
        if (!widget.isCaller) {
          _handleOffer(data['sdp'], data['sdp_type']);
        }
        break;
      case 'rtc_answer':
        if (widget.isCaller) {
          _handleAnswer(data['sdp'], data['sdp_type']);
        }
        break;
      case 'rtc_ice_candidate':
        _handleIceCandidate(data['candidate']);
        break;
    }
  }

  // WebRTC初始化
  Future<void> _initWebRTC() async {
    await _getUserMedia();
    _peerConnection = await createPeerConnection(
      {
        'iceServers': [
          {'url': 'stun:stun.l.google.com:19302'},
          {'url': 'stun:124.222.83.66:3478'},
          {
            'url': 'turn:124.222.83.66:3478',
            'username': 'your_username',
            'credential': 'your_password',
          },
        ],
      },
      {
        'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
        'optional': [],
      },
    );
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });
    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      _sendRtcIceCandidate(candidate.toMap());
    };
    _peerConnection?.onAddStream = (MediaStream stream) {
      setState(() {
        _remoteStream = stream;
        _remoteRenderer.srcObject = _remoteStream;
      });
    };
    _peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      setState(() {
        _connectionStatus = state.toString().split('.').last;
      });
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('连接已断开: ${state.toString().split('.').last}')),
        );
      }
    };
    _peerConnection?.onSignalingState = (RTCSignalingState state) {
      // ...可选调试输出...
    };
  }

  Future<void> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      setState(() {
        _localRenderer.srcObject = _localStream;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('无法访问摄像头/麦克风: $e')));
    }
  }

  // 创建并发送Offer
  Future<void> _createAndSendOffer() async {
    if (_peerConnection == null) return;
    try {
      RTCSessionDescription offer = await _peerConnection!.createOffer({
        'offerToReceiveVideo': 1,
        'offerToReceiveAudio': 1,
      });
      await _peerConnection!.setLocalDescription(offer);
      _sendRtcOffer(offer.sdp ?? '', offer.type ?? '');
    } catch (e) {
      // ...异常处理...
    }
  }

  // 处理Offer
  Future<void> _handleOffer(String sdp, String type) async {
    if (_peerConnection == null) return;
    try {
      await _peerConnection!.setRemoteDescription(RTCSessionDescription(sdp, type));
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _sendRtcAnswer(answer.sdp ?? '', answer.type ?? '');
    } catch (e) {
      // ...异常处理...
    }
  }

  // 处理Answer
  Future<void> _handleAnswer(String sdp, String type) async {
    if (_peerConnection == null) return;
    try {
      await _peerConnection!.setRemoteDescription(RTCSessionDescription(sdp, type));
    } catch (e) {
      // ...异常处理...
    }
  }

  // 处理ICE候选
  Future<void> _handleIceCandidate(Map<String, dynamic> candidate) async {
    if (_peerConnection == null) return;
    try {
      await _peerConnection!.addCandidate(RTCIceCandidate(
        candidate['candidate'],
        candidate['sdpMid'],
        candidate['sdpMLineIndex'],
      ));
    } catch (e) {
      // ...异常处理...
    }
  }

  // 显示重连对话框
  void _showReconnectDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('连接断开'),
            content: const Text('WebSocket连接已断开，是否尝试重连？'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _webSocketService.connect(
                    'wss://124.222.83.66:8023/ws',
                  ); // 尝试重连
                },
                child: const Text('重连'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _endCall(); // 结束通话
                },
                child: const Text('结束通话'),
              ),
            ],
          ),
    );
  }

  // 处理通话结束
  void _handleCallEnd() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('对方已结束通话')));
    _endCall();
  }

  // 结束通话
  void _endCall() {
    // 结束通话并返回上一页
    _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    context.router.pop();
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = _isCameraOn;
    });
  }

  void _toggleMic() {
    setState(() {
      _isMicOn = !_isMicOn;
    });
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = _isMicOn;
    });
  }

  void _switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // 实际应用中需要实现扬声器切换逻辑
    // 可能需要使用audio_session或其他插件
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('视频通话 ${widget.userId ?? ''}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _connectionStatus,
                style: TextStyle(
                  color: _isConnecting ? Colors.yellow : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 远程视频视图 (全屏显示)
          Positioned.fill(
            child:
                _remoteRenderer.srcObject != null
                    ? RTCVideoView(_remoteRenderer)
                    : Container(
                      color: Colors.black,
                      child: const Center(
                        child: Text(
                          '等待对方加入...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
          ),
          // 本地视频视图 (小窗显示)
          Positioned(
            top: 20,
            right: 20,
            width: 100,
            height: 150,
            child:
                _localRenderer.srcObject != null
                    ? RTCVideoView(_localRenderer, mirror: true) // 本地摄像头通常需要镜像
                    : Container(color: Colors.grey),
          ),
          // 控制按钮
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'camera',
                  onPressed: _toggleCamera,
                  child: Icon(
                    _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  ),
                  backgroundColor: _isCameraOn ? Colors.blue : Colors.red,
                ),
                FloatingActionButton(
                  heroTag: 'mic',
                  onPressed: _toggleMic,
                  child: Icon(_isMicOn ? Icons.mic : Icons.mic_off),
                  backgroundColor: _isMicOn ? Colors.blue : Colors.red,
                ),
                FloatingActionButton(
                  heroTag: 'speaker',
                  onPressed: _toggleSpeaker,
                  child: Icon(
                    _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                  ),
                  backgroundColor: Colors.blue,
                ),
                FloatingActionButton(
                  heroTag: 'switch_camera',
                  onPressed: _switchCamera,
                  child: Icon(Icons.switch_camera),
                ),
                FloatingActionButton(
                  heroTag: 'end_call',
                  onPressed: _endCall,
                  child: Icon(Icons.call_end),
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
