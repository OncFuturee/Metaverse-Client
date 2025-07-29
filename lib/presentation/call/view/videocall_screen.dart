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
  List<RTCIceCandidate> _iceCandidates = []; // 存储ICE候选者,等待接听方准备好之后再发送

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

  // 调试面板开始
  bool _showDebugPanel = false;
  String _signalingState = '';
  String _iceConnectionState = '';
  List<Map<String, dynamic>> _remoteIceCandidates = [];
  // 调试面板结束

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    _webSocketService = WebSocketService();
    _setupWebSocketListener();
    _initWebRTC().then((_){
      // 初始化完成后，发送呼叫请求
      if (widget.isCaller) {
        _sendCallRequest();
      }
      
      // 如果是接听方，需要在WebRTC初始化完成后通知服务器已接听（通知呼叫方已准备好接听）
      if (!widget.isCaller) {
        WebSocketService().sendMessage('video_call', {
          'type': 'call_accept',
          'caller_userid': widget.userId,
          'callee_userid': DebugConfig.instance.params['userId'],
        });
      }
    });

    // 设置呼叫双方的用户ID
    if (widget.isCaller) {
      _callerUserId = DebugConfig.instance.params['userId'];
      _calleeUserId = widget.userId;
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

  // 信令消息处理
  void _handleSignalingMessage(WebSocketMessage message) {
    final data = message.data as Map<String, dynamic>?;
    if (data == null) return;
    // 只处理与本通话相关的消息
    if (data['caller_userid'] != _callerUserId || data['callee_userid'] != _calleeUserId) return;
    switch (data['type']) {
      case 'call_accept': // 对方接听电话
        if (widget.isCaller) {
          setState(() { _isCallAccepted = true; });
          _createAndSendOffer();
        }
        break;
      case 'call_reject': // 对方拒绝电话
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('对方已拒绝通话')));
        _endCall();
        break;
      case 'call_end': // 对方结束通话
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('通话已结束')));
        _handleCallEnd();
        break;
      case 'rtc_offer': // 收到呼叫方发来的Offer
        if (!widget.isCaller) {
          _handleOffer(data['sdp'], data['sdp_type']);
        }
        break;
      case 'rtc_answer': // 收到接听方发来的Answer
        if (widget.isCaller) {
          _handleAnswer(data['sdp'], data['sdp_type']);
        }
        break;
      case 'rtc_ice_candidate': // 收到对方的ICE候选
        _handleIceCandidate(data['candidate']);
        break;
    }
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

  // 发送结束信令
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

  // WebRTC初始化
  Future<void> _initWebRTC() async {
    await _getUserMedia();
    _peerConnection = await createPeerConnection(
      {
        'iceServers': [
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
    // 添加本地媒体轨道流到PeerConnection
    _localStream?.getTracks().forEach((track) {
      debugPrint("添加本地轨道: ${track.kind}");
      _peerConnection?.addTrack(track, _localStream!);
    });
    // 自动通过 STUN/TURN 服务器收集本地网络信息（如本地 IP、公网 IP 等）。
    // 每生成一个有效的候选者，onIceCandidate 就会被触发，并传入该候选者对象（RTCIceCandidate）
    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      // 如果是呼叫方，先收集ICE候选者，等接听方准备好后再发送
      // 如果是接听方，直接发送ICE候选者
      if (widget.isCaller) {
        _iceCandidates.add(candidate); // 收集到的候选者需要在收到接听方的Offer Answer后发送
        debugPrint("呼叫方-收集本地ICE候选：${candidate.toMap().toString()}");
      } else {
        _sendRtcIceCandidate(candidate.toMap());
        debugPrint("接听方-发送本地ICE候选：${candidate.toMap().toString()}");
      }
    };
    _peerConnection?.onAddStream = (MediaStream stream) {
      debugPrint("添加远程流");
      setState(() {
        _remoteStream = stream;
        _remoteRenderer.srcObject = _remoteStream;
      });
    };
    _peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      setState(() {
        _connectionStatus = state.toString().split('.').last;
        // 调试面板开始
        _iceConnectionState = state.toString();
        // 调试面板结束
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
      debugPrint("Signaling State: ${state.toString().split('.').last}");
      // 调试面板开始
      setState(() {
        _signalingState = state.toString();
      });
      // 调试面板结束
    };
  }

  Future<void> _getUserMedia() async {
    debugPrint("获取UserMedia...");
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
      debugPrint("创建Offer并发送");
    if (_peerConnection == null) {
      debugPrint("PeerConnection未初始化");
      return;
    }
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
    debugPrint("接听方-处理Offer请求:sdp=$sdp,type=$type");
    if (_peerConnection == null) {
      debugPrint("PeerConnection未初始化");
      return;
    }
    try {
      await _peerConnection!.setRemoteDescription(RTCSessionDescription(sdp, type));
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _sendRtcAnswer(answer.sdp ?? '', answer.type ?? '');
      debugPrint("接听方-发送Offer Answer:sdp=$sdp,type=$type");
    } catch (e) {
      // ...异常处理...
    }
  }

  // 处理Answer
  Future<void> _handleAnswer(String sdp, String type) async {
    debugPrint("呼叫方-处理接听方的Offer Answer:sdp=$sdp,type=$type");
    if (_peerConnection == null) {
      debugPrint("_handleAnswer:PeerConnection未初始化");
      return;
    }
    try {
      await _peerConnection!.setRemoteDescription(RTCSessionDescription(sdp, type));
      // 向接听方发送之前收集的ICE候选者
      for (var candidate in _iceCandidates) {
        _sendRtcIceCandidate(candidate.toMap());
        debugPrint("呼叫方-发送本地ICE候选者: ${candidate.toMap()}");
      }
    } catch (e) {
      // ...异常处理...
    }
  }

  // 处理ICE候选
  Future<void> _handleIceCandidate(Map<String, dynamic> candidate) async {
    // 调试面板开始
    setState(() {
      _remoteIceCandidates.add(candidate);
    });
    // 调试面板结束
    if (_peerConnection == null) {
      debugPrint("_handleIceCandidate:PeerConnection未初始化");
      return;
    }
    try {
      await _peerConnection!.addCandidate(RTCIceCandidate(
        candidate['candidate'],
        candidate['sdpMid'],
        candidate['sdpMLineIndex'],
      ));
      debugPrint("添加远程ICE候选者: $candidate");
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
          // 调试面板开始
          Positioned(
            bottom: 90,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'debug_panel_toggle',
                  onPressed: () {
                    setState(() {
                      _showDebugPanel = !_showDebugPanel;
                    });
                  },
                  child: Icon(_showDebugPanel ? Icons.bug_report : Icons.bug_report_outlined),
                  backgroundColor: Colors.orange,
                ),
                if (_showDebugPanel)
                  Container(
                    width: 320,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('【WebRTC调试面板】'),
                          Text('PeerConnection: ${_peerConnection != null ? '已初始化' : '未初始化'}'),
                          Text('SignalingState: $_signalingState'),
                          Text('ICEConnectionState: $_iceConnectionState'),
                          Text('本地流: ${_localStream != null ? '有' : '无'}'),
                          Text('远程流: ${_remoteStream != null ? '有' : '无'}'),
                          Text('ICE候选数: ${_iceCandidates.length}'),
                          Text('远程ICE候选数: ${_remoteIceCandidates.length}'),
                          Text('isCaller: ${widget.isCaller}'),
                          Text('isCallAccepted: $_isCallAccepted'),
                          Text('isCallEnded: $_isCallEnded'),
                          Text('WebSocket连接: $_isWebSocketConnected'),
                          Text('连接状态: $_connectionStatus'),
                          const Divider(color: Colors.greenAccent),
                          Text('本地ICE候选列表:'),
                          SizedBox(
                            height: 60,
                            child: ListView(
                              children: _iceCandidates.map((c) => Text(c.toMap().toString(), maxLines: 1, overflow: TextOverflow.ellipsis)).toList(),
                            ),
                          ),
                          Text('远程ICE候选列表:'),
                          SizedBox(
                            height: 60,
                            child: ListView(
                              children: _remoteIceCandidates.map((c) => Text(c.toString(), maxLines: 1, overflow: TextOverflow.ellipsis)).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 调试面板结束
        ],
      ),
    );
  }
}
