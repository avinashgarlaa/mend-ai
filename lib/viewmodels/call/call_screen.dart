import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mend_ai/services/signal_service.dart';
import 'package:mend_ai/providers/user_provider.dart';

final signalingProvider = ChangeNotifierProvider<SignalingService>((ref) {
  return SignalingService();
});

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key});

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupCall();
  }

  Future<void> _setupCall() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    final user = ref.read(userProvider);
    final sessionId = user?.currentSessionId;
    final userId = user?.id;

    if (sessionId == null || userId == null) {
      print('❌ Cannot start call: sessionId or userId is null');
      return;
    }

    final signaling = ref.watch(signalingProvider);

    signaling.init(
      sessionId: sessionId,
      userId: userId,
      localRenderer: _localRenderer,
      remoteRenderer: _remoteRenderer,
    );

    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    ref.read(signalingProvider).dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signaling = ref.watch(signalingProvider);

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
        backgroundColor: Colors.black,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
          Positioned(
            right: 20,
            bottom: 100,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: const Text(
              "Live Call",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (signaling.warningText.isNotEmpty)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Text(
                signaling.warningText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
