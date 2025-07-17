import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SignalingService extends ChangeNotifier {
  late IO.Socket _socket;
  late String _sessionId;
  late String _userId;
  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  String _warningText = '';
  String get warningText => _warningText;

  void setWarningText(String text) {
    _warningText = text;
    notifyListeners();
  }

  void init({
    required String sessionId,
    required String userId,
    required RTCVideoRenderer localRenderer,
    required RTCVideoRenderer remoteRenderer,
  }) async {
    _sessionId = sessionId;
    _userId = userId;
    _localRenderer = localRenderer;
    _remoteRenderer = remoteRenderer;

    _initSocket();
    await _startLocalStream();
    _createPeerConnection();
  }

  void _initSocket() {
    _socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      _socket.emit('join', {'sessionId': _sessionId, 'userId': _userId});
    });

    _socket.on('warning', (data) {
      setWarningText(data['message']);
    });

    _socket.on('offer', (data) async {
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
      final answer = await _peerConnection?.createAnswer();
      await _peerConnection?.setLocalDescription(answer!);
      _socket.emit('answer', {
        'sessionId': _sessionId,
        'userId': _userId,
        'sdp': answer!.sdp,
        'type': answer.type,
      });
    });

    _socket.on('answer', (data) async {
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
    });

    _socket.on('ice-candidate', (data) {
      _peerConnection?.addCandidate(
        RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        ),
      );
    });
  }

  Future<void> _startLocalStream() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    _localStream = stream;
    _localRenderer.srcObject = stream;
  }

  void _createPeerConnection() async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(config);

    _peerConnection?.onIceCandidate = (candidate) {
      _socket.emit('ice-candidate', {
        'sessionId': _sessionId,
        'userId': _userId,
        'candidate': candidate.toMap(),
      });
    };

    _peerConnection?.onTrack = (event) {
      _remoteRenderer.srcObject = event.streams.first;
    };

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    final offer = await _peerConnection?.createOffer();
    await _peerConnection?.setLocalDescription(offer!);
    _socket.emit('offer', {
      'sessionId': _sessionId,
      'userId': _userId,
      'sdp': offer!.sdp,
      'type': offer.type,
    });
  }

  void dispose() {
    _peerConnection?.close();
    _localStream?.dispose();
    _socket.disconnect();
    super.dispose();
  }
}
