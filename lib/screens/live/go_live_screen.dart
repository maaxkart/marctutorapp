import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import '../../theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
// ─────────────────────────────────────────────────────────────────────────────
//  GoLiveScreen — 100ms SDK  (replaces RTMP / apivideo_live_stream)
//
//  The backend provides:
//    room_id    → 100ms room identifier (stored in DB)
//    host_token → JWT for tutor to join as "host" role
//
//  Flutter uses: hmssdk_flutter (pub.dev/packages/hmssdk_flutter)
//
//  Flow:
//   1. Tutor taps "Go Live" in LiveScreen
//   2. LiveScreen calls POST /api/live-sessions/{id}/start
//      → receives { room_id, host_token }
//   3. LiveScreen pushes GoLiveScreen with those credentials
//   4. GoLiveScreen joins the 100ms room as host
//   5. Tutor taps END → leaves room → pop(true) → LiveScreen calls /end API
//   6. Backend ends 100ms room, downloads recording, uploads to Bunny
// ─────────────────────────────────────────────────────────────────────────────

class GoLiveScreen extends StatefulWidget {
  final String roomId;
  final String hostToken;
  final String title;
  final int sessionId;
  final String subject;

  const GoLiveScreen({
    required this.roomId,
    required this.hostToken,
    required this.title,
    required this.sessionId,
    this.subject = '',
    super.key,
  });

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen>
    with WidgetsBindingObserver
    implements HMSUpdateListener, HMSActionResultListener {


  // ── 100ms SDK ────────────────────────────────────────────────────────────
  late HMSSDK _hmsSDK;

  // ── Peers & tracks ───────────────────────────────────────────────────────
  HMSPeer? _localPeer;
  HMSVideoTrack? _localVideoTrack;
  final List<HMSPeer> _peers = [];

  // ── State flags ──────────────────────────────────────────────────────────
  bool _isJoining   = false;
  bool _isStreaming  = false;   // true once local peer has joined & video is on
  bool _isMuted     = false;
  bool _isVideoOff  = false;
  bool _isFront     = true;
  String? _errorMsg;

  // ── UI ───────────────────────────────────────────────────────────────────
  bool _showChat = false;
  final List<Map<String, String>> _chatMessages = [];

  Timer? _timer;
  int _elapsed  = 0;
  int _viewers  = 0;   // count of non-host peers

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAndJoin();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _hmsSDK.removeUpdateListener(listener: this);
    // Leave room cleanly if disposed unexpectedly
    if (_isStreaming) {
      _hmsSDK.leave(hmsActionResultListener: null);
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Init 100ms SDK and join as host
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _initAndJoin() async {

    setState(() => _isJoining = true);

    try {

      // 🔥 REQUEST CAMERA + MIC
      final cameraStatus =
      await Permission.camera.request();

      final micStatus =
      await Permission.microphone.request();

      if (!cameraStatus.isGranted ||
          !micStatus.isGranted) {

        setState(() {
          _isJoining = false;
          _errorMsg =
          "Camera & microphone permission denied";
        });

        return;
      }

      _hmsSDK = HMSSDK();

      await _hmsSDK.build();

      _hmsSDK.addUpdateListener(listener: this);

      final config = HMSConfig(
        authToken: widget.hostToken,
        userName: 'Tutor',
      );

      await _hmsSDK.join(config: config);

    } catch (e) {

      if (mounted) {

        setState(() {

          _isJoining = false;

          _errorMsg =
          'Failed to join live:\n$e';
        });
      }
    }
  }
  // ─────────────────────────────────────────────────────────────────────────
  //  End stream → leave room → pop(true) so LiveScreen calls /end API
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _endStream() async {
    final confirm = await _showEndDialog();
    if (confirm != true) return;
    HapticFeedback.heavyImpact();
    _timer?.cancel();

    setState(() {
      _localVideoTrack = null;
      _isVideoOff = true;
    });
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // ✅ Just LEAVE — backend will call endRoom via /end API
      // endRoom from Flutter kills the room instantly before
      // 100ms can finalize the recording → webhook never fires
      await _hmsSDK.leave(hmsActionResultListener: null);
    } catch (_) {}

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _toggleMic() async {
    HapticFeedback.selectionClick();
    await _hmsSDK.toggleMicMuteState();
    setState(() => _isMuted = !_isMuted);
  }

  Future<void> _toggleVideo() async {
    HapticFeedback.selectionClick();
    await _hmsSDK.toggleCameraMuteState();
    setState(() => _isVideoOff = !_isVideoOff);
  }

  Future<void> _switchCamera() async {
    HapticFeedback.selectionClick();
    await _hmsSDK.switchCamera(hmsActionResultListener: this);
    setState(() => _isFront = !_isFront);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  String get _elapsedFormatted {
    final h = _elapsed ~/ 3600;
    final m = (_elapsed % 3600) ~/ 60;
    final s = _elapsed % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
    }
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  Future<bool?> _showEndDialog() => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('End Live Session?',
          style: TextStyle(fontWeight: FontWeight.w800)),
      content: Text(
        _isStreaming
            ? 'Your session of $_elapsedFormatted will end.\nThe recording will be saved automatically.'
            : 'Leave the session?',
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('End Now', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  // ═════════════════════════════════════════════════════════════════════════
  //  HMSUpdateListener callbacks
  // ═════════════════════════════════════════════════════════════════════════

  @override
  void onJoin({required HMSRoom room}) {
    if (mounted) {
      setState(() {
        _isJoining  = false;
        _isStreaming = true;
      });
      _startTimer();
    }
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (!mounted) return;
    setState(() {
      if (update == HMSPeerUpdate.peerJoined) {
        _peers.add(peer);
      } else if (update == HMSPeerUpdate.peerLeft) {
        _peers.removeWhere((p) => p.peerId == peer.peerId);
      }
      if (peer.isLocal) _localPeer = peer;
      _viewers = _peers.where((p) => !p.isLocal).length;
    });
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    if (!mounted) return;
    if (peer.isLocal && track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      setState(() {
        _localVideoTrack = (track is HMSVideoTrack) ? track : _localVideoTrack;
      });
    }
  }

  @override
  void onError({required HMSException error}) {
    if (mounted) {
      setState(() {
        _isJoining = false;
        _errorMsg  = '100ms error: ${error.message} (${error.code?.errorCode})';
      });
    }
  }

  @override
  void onMessage({required HMSMessage message}) {
    if (!mounted) return;
    setState(() {
      _chatMessages.insert(0, {
        'name':    message.sender?.name ?? 'Student',
        'message': message.message,
      });
    });
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onReconnecting() {}

  @override
  void onReconnected() {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onChangeTrackStateRequest({required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onRemovedFromRoom({required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {}

  // HMSActionResultListener
  @override
  void onSuccess({HMSActionResultListenerMethod methodType = HMSActionResultListenerMethod.unknown, Map<String, dynamic>? arguments}) {}

  @override
  void onException({HMSActionResultListenerMethod methodType = HMSActionResultListenerMethod.unknown, Map<String, dynamic>? arguments, required HMSException hmsException}) {}
  @override
  void onHMSError({required HMSException error}) {
    if (mounted) {
      setState(() {
        _isJoining = false;
        _errorMsg  = '100ms error: ${error.message} (${error.code?.errorCode})';
      });
    }
  }
  // ═════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      backgroundColor: Colors.black,
      body: _errorMsg != null
          ? _buildErrorState()
          : _isJoining
          ? _buildLoadingState()
          : _buildLiveView(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 16),
        Text('Connecting to live room...',
            style: TextStyle(color: Colors.white70, fontSize: 14)),
        SizedBox(height: 8),
        Text('Powered by 100ms',
            style: TextStyle(color: Colors.white30, fontSize: 11)),
      ]),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.videocam_off_rounded, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              _errorMsg ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _errorMsg = null);
                _initAndJoin();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back',
                  style: TextStyle(color: Colors.white54)),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildLiveView() {
    return Stack(children: [
      // ── Local camera preview ────────────────────────────────────────────
      Positioned.fill(
        child: _localVideoTrack != null && !_isVideoOff
            ? HMSVideoView(
          track: _localVideoTrack!,
          matchParent: true,
          scaleType: ScaleType.SCALE_ASPECT_FILL,
        )
            : Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(Icons.videocam_off_rounded,
                color: Colors.white38, size: 64),
          ),
        ),
      ),

      // ── Top gradient ────────────────────────────────────────────────────
      Positioned(
        top: 0, left: 0, right: 0, height: 180,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
        ),
      ),

      // ── Bottom gradient ─────────────────────────────────────────────────
      Positioned(
        bottom: 0, left: 0, right: 0, height: 200,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
        ),
      ),

      // ── Top bar ─────────────────────────────────────────────────────────
      SafeArea(child: _buildTopBar()),

      // ── Bottom controls ──────────────────────────────────────────────────
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: SafeArea(child: _buildBottomControls()),
      ),

      // ── Chat panel ──────────────────────────────────────────────────────
      if (_showChat)
        Positioned(
          right: 0, top: 0, bottom: 0,
          width: MediaQuery.of(context).size.width * 0.55,
          child: _buildChatPanel(),
        ),
    ]);
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(children: [
        // Close / back button
        GestureDetector(
          onTap: () async {
            if (_isStreaming) {
              await _endStream();
            } else {
              if (mounted) Navigator.pop(context);
            }
          },
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.close_rounded,
                color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 10),

        // Title & subject
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (widget.subject.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(widget.subject,
                    style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            const SizedBox(height: 2),
            Text(widget.title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),

        // Live badge + viewer count
        if (_isStreaming) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(8)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.circle, size: 7, color: Colors.white),
              SizedBox(width: 4),
              Text('LIVE',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1)),
            ]),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.black45, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.remove_red_eye_rounded,
                  size: 12, color: Colors.white70),
              const SizedBox(width: 4),
              Text(_viewers.toString(),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Timer
        if (_isStreaming)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20)),
            child: Text(_elapsedFormatted,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
          ),

        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          // Mic toggle
          _liveBtn(
            icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label: _isMuted ? 'Muted' : 'Mic',
            active: _isMuted,
            activeColor: Colors.red,
            onTap: _toggleMic,
          ),

          // Camera flip
          _liveBtn(
            icon: Icons.flip_camera_android_rounded,
            label: 'Flip',
            onTap: _switchCamera,
          ),

          // END button (big red)
          GestureDetector(
            onTap: _endStream,
            child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2)
                ],
              ),
              child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                    SizedBox(height: 2),
                    Text('END',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2)),
                  ]),
            ),
          ),

          // Video toggle
          _liveBtn(
            icon: _isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
            label: _isVideoOff ? 'Video Off' : 'Video',
            active: _isVideoOff,
            activeColor: Colors.orange,
            onTap: _toggleVideo,
          ),

          // Chat toggle
          _liveBtn(
            icon: Icons.chat_bubble_rounded,
            label: 'Chat',
            active: _showChat,
            activeColor: AppColors.primary,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _showChat = !_showChat);
            },
          ),
        ]),
      ]),
    );
  }

  Widget _liveBtn({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool active = false,
    Color activeColor = Colors.white,
  }) {
    final color = active ? activeColor : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: active ? activeColor.withOpacity(0.2) : Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
                color: active ? activeColor.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                width: 0.5),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 5),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.85))),
      ]),
    );
  }

  Widget _buildChatPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      ),
      child: Column(children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(children: [
              const Text('Live Chat',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showChat = false),
                child: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
              ),
            ]),
          ),
        ),
        const Divider(color: Colors.white12, height: 1),
        Expanded(
          child: _chatMessages.isEmpty
              ? const Center(
              child: Text('No messages yet',
                  style: TextStyle(color: Colors.white38, fontSize: 12)))
              : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _chatMessages.length,
            itemBuilder: (_, i) {
              final msg = _chatMessages[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '${msg['name']}: ',
                      style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 11),
                    ),
                    TextSpan(
                      text: msg['message'],
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        // Send message field (functional)
        _ChatInputField(
          onSend: (text) async {

            if (text.trim().isEmpty) return;

            try {

              await _hmsSDK.sendBroadcastMessage(

                message: text,

                type: 'chat',

                hmsActionResultListener: this,
              );

            } catch (e) {

              debugPrint(e.toString());
            }
          },
        ),
      ]),
    );
  }


}

// ─────────────────────────────────────────────────────────────────────────────
//  Simple chat input widget
// ─────────────────────────────────────────────────────────────────────────────
class _ChatInputField extends StatefulWidget {
  final ValueChanged<String> onSend;
  const _ChatInputField({required this.onSend});

  @override
  State<_ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<_ChatInputField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'Type a message...',
              hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
              border: InputBorder.none,
              isDense: true,
            ),
            onSubmitted: (v) {
              widget.onSend(v);
              _ctrl.clear();
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.onSend(_ctrl.text);
            _ctrl.clear();
          },
          child: const Icon(Icons.send_rounded, color: Colors.white54, size: 18),
        ),
      ]),
    );
  }
}