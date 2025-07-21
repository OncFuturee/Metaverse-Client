import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class VideoCallScreen extends StatefulWidget {
  final String? roomId; // 可选的房间ID参数

  const VideoCallScreen({Key? key, @queryParam this.roomId}) : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // WebRTC 相关的变量
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool _isCameraOn = true;
  bool _isMicOn = true;
  bool _isSpeakerOn = true; // 假设有扬声器控制

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    _initWebRTC();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  Future<void> _initWebRTC() async {
    // 1. 获取本地媒体流
    await _getUserMedia();

    // 2. 创建 PeerConnection
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'} // STUN 服务器
      ]
    }, {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    });

    // 3. 将本地流添加到 PeerConnection
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    // 4. 设置 PeerConnection 的事件监听
    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      // 当生成 ICE 候选者时，发送给远程对等端
      print('ICE Candidate: ${candidate.toMap()}');
      // TODO: 将此 ICE 候选者通过您的信令服务器发送给远程对等端
    };

    _peerConnection?.onAddStream = (MediaStream stream) {
      // 当接收到远程流时
      print('Remote stream added: ${stream.id}');
      setState(() {
        _remoteStream = stream;
        _remoteRenderer.srcObject = _remoteStream;
      });
    };

    _peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      print('ICE Connection State: $state');
    };

    _peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling State: $state');
    };

    // 5. 创建 Offer (如果此端发起呼叫)
    // 实际应用中，这通常在用户点击“呼叫”按钮后触发
    // RTCSessionDescription offer = await _peerConnection!.createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
    // await _peerConnection!.setLocalDescription(offer);
    // TODO: 将此 Offer 通过您的信令服务器发送给远程对等端

    // 6. 监听远程 Offer/Answer 和 ICE 候选者
    // TODO: 您需要在此处集成您的信令服务器，接收远程的 Offer/Answer 和 ICE 候选者
    // 当收到远程 Offer 时：
    // await _peerConnection!.setRemoteDescription(remoteOffer);
    // RTCSessionDescription answer = await _peerConnection!.createAnswer();
    // await _peerConnection!.setLocalDescription(answer);
    // TODO: 将此 Answer 发送给远程对等端

    // 当收到远程 Answer 时：
    // await _peerConnection!.setRemoteDescription(remoteAnswer);

    // 当收到远程 ICE Candidate 时：
    // await _peerConnection!.addCandidate(remoteCandidate);
  }

  Future<void> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user', // 或 'environment' 用于后置摄像头
      },
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      setState(() {
        _localRenderer.srcObject = _localStream;
      });
    } catch (e) {
      print('获取本地媒体流失败: $e');
      // 处理错误，例如显示提示
    }
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

  void _endCall() {
    // 结束通话并返回上一页
    _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    context.router.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('视频通话 ${widget.roomId ?? ''}'),
      ),
      body: Stack(
        children: [
          // 远程视频视图 (全屏显示)
          Positioned.fill(
            child: _remoteRenderer.srcObject != null
                ? RTCVideoView(_remoteRenderer)
                : Container(color: Colors.black),
          ),
          // 本地视频视图 (小窗显示)
          Positioned(
            top: 20,
            right: 20,
            width: 100,
            height: 150,
            child: _localRenderer.srcObject != null
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
                  child: Icon(_isCameraOn ? Icons.videocam : Icons.videocam_off),
                  backgroundColor: _isCameraOn ? Colors.blue : Colors.red,
                ),
                FloatingActionButton(
                  heroTag: 'mic',
                  onPressed: _toggleMic,
                  child: Icon(_isMicOn ? Icons.mic : Icons.mic_off),
                  backgroundColor: _isMicOn ? Colors.blue : Colors.red,
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