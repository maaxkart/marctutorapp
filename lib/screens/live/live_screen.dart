import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'go_live_screen.dart';
import 'schedule_session_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  LiveScreen — 2 Tabs: Upcoming · Recordings
//
//  LIVE:       100ms  (tutor joins as host, students join as viewer)
//  RECORDINGS: Bunny Stream VOD  (HLS played via video_player + chewie)
//
//  Tutor flow:
//   Upcoming tab → tap "Go Live"
//     → POST /api/live-sessions/{id}/start
//     → receives { room_id, host_token }
//     → push GoLiveScreen(roomId, hostToken, ...)
//     → on END pop(true) → POST /api/live-sessions/{id}/end
//     → jump to Recordings tab
//
//  Student flow:
//   GET /api/live-sessions/current  → receives { viewer_token, room_id }
//   (Student joins via a separate StudentLiveScreen using the viewer_token)
// ─────────────────────────────────────────────────────────────────────────────
class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;

  List<Map<String, dynamic>> _upcomingClasses = [];
  List<Map<String, dynamic>> _recordings      = [];
  bool _isLoading = true;

  /// Tracks which class is currently being streamed
  Map<String, dynamic>? _activeClass;

  static const String _bunnyCdnBase = 'https://vz-645d8a93-295.b-cdn.net';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Data loading
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _loadData() async {
    try {
      final upcoming     = await ApiService.upcomingLive();
      final recordingsList = await ApiService.recordings();
      if (mounted) {
        setState(() {
          _upcomingClasses = List<Map<String, dynamic>>.from(upcoming);
          _recordings      = List<Map<String, dynamic>>.from(recordingsList);
          _isLoading       = false;
        });
      }
    } catch (e) {
      debugPrint('_loadData error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Builds a Bunny HLS URL from session data (for recordings tab)
  String _buildHlsUrl(Map<String, dynamic> data) {
    final existing = (data['hls_url'] ?? data['recording_url'] ?? '').toString().trim();
    if (existing.isNotEmpty && existing.startsWith('http')) return existing;
    final videoId = (data['bunny_video_id'] ?? '').toString().trim();
    if (videoId.isNotEmpty) return '$_bunnyCdnBase/$videoId/playlist.m3u8';
    return '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TUTOR: Go Live → 100ms GoLiveScreen
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _startClass(Map<String, dynamic> cls) async {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // POST /api/live-sessions/{id}/start
      // Returns: { success, room_id, host_token }
      final result = await ApiService.startClass(cls['id']);
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss spinner

      if (result['success'] != true) {
        _showSnack(result['message'] ?? 'Failed to start class', color: Colors.orange);
        return;
      }

      final roomId    = (result['room_id']    ?? '').toString().trim();
      final hostToken = (result['host_token'] ?? '').toString().trim();

      if (roomId.isEmpty || hostToken.isEmpty) {
        _showSnack('Missing room_id or host_token from server.', color: Colors.orange);
        return;
      }

      setState(() => _activeClass = {...cls, 'room_id': roomId});

      // ── Push GoLiveScreen (100ms) ────────────────────────────────────
      final ended = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => GoLiveScreen(
            roomId:    roomId,
            hostToken: hostToken,
            title:     (cls['title']   ?? 'Live Class').toString(),
            sessionId: cls['id'],
            subject:   (cls['subject'] ?? '').toString(),
          ),
        ),
      );

      if (!mounted) return;

      if (ended == true) {
        try {
          debugPrint('🔴 Calling endClass for session ${cls['id']}');
          final result = await ApiService.endClass(cls['id']);
          debugPrint('🔴 endClass result: $result');
        } catch (e) {
          debugPrint('🔴 endClass FAILED: $e'); // was silently hidden before
          _showSnack('Warning: Could not end session cleanly: $e');
        }

        setState(() => _activeClass = null);
        await _loadData();
        if (!mounted) return;
        _tabCtrl.animateTo(1);
        _showSnack('✅ Class ended. Recording is being processed.', color: Colors.green);
      } else {
        setState(() => _activeClass = null);
      }
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      _showSnack('Error: $e');
    }
  }



  void _showSnack(String msg, {Color color = Colors.black87}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openPlayer(String hlsUrl, String title, {bool isRecording = false}) {
    if (hlsUrl.isEmpty) {
      _showSnack('Recording not ready yet. Try again shortly.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LivePlayerScreen(
          hlsUrl: hlsUrl,
          title: title,
          isRecording: isRecording,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabCtrl,
        children: [
          _buildUpcomingTab(),
          _buildRecordingsTab(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: AppColors.border,
      titleSpacing: 16,
      title: const Text(
        'My Classes',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            HapticFeedback.mediumImpact();
            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => const ScheduleSessionScreen(),
              ),
            );
            // Refresh upcoming list if session was created
            if (created == true && mounted) {
              await _loadData();
              _tabCtrl.animateTo(0); // jump to Upcoming tab
              _showSnack(
                '✅ Class scheduled successfully!',
                color: Colors.green,
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 15),
              SizedBox(width: 5),
              Text('Schedule',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ]),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(46),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Recordings'),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  TAB 1 — UPCOMING
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildUpcomingTab() {
    if (_upcomingClasses.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('📅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('No upcoming classes',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadData, child: const Text('Refresh')),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        itemCount: _upcomingClasses.length,
        itemBuilder: (_, i) => _buildUpcomingCard(_upcomingClasses[i]),
      ),
    );
  }

  Widget _buildUpcomingCard(Map<String, dynamic> cls) {
    final isActive = _activeClass != null && _activeClass!['id'] == cls['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? Colors.red.withValues(alpha: 0.45) : AppColors.border,
          width: isActive ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14)),
              child: const Center(
                  child: Text('📚', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _pill((cls['status'] ?? 'Upcoming').toString(),
                      AppColors.primary.withValues(alpha: 0.1), AppColors.primary),
                  const SizedBox(width: 6),
                  if ((cls['subject'] ?? '').toString().isNotEmpty)
                    _pill(cls['subject'].toString(), AppColors.background,
                        AppColors.textMuted, border: AppColors.border),
                ]),
                const SizedBox(height: 6),
                Text(
                  (cls['title'] ?? '').toString(),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          ]),
        ),

        // Meta
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Row(children: [
            _metaChip(Icons.access_time_rounded,
                _formatDateTime(cls['scheduled_at']),
                AppColors.primary, AppColors.primarySoft),
            const SizedBox(width: 8),
            if ((cls['duration'] ?? '').toString().isNotEmpty)
              _metaChip(Icons.timer_outlined, cls['duration'].toString(),
                  AppColors.textMuted, AppColors.background),
            const Spacer(),
            Text('${cls['students_count'] ?? 0} enrolled',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ]),
        ),

        // Action buttons
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: Row(children: [
            // Remind
            Expanded(
              child: GestureDetector(
                onTap: () => HapticFeedback.selectionClick(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_outlined,
                            size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 5),
                        Text('Remind',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ]),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Go Live / Live Now  ← now launches 100ms
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: isActive ? null : () => _startClass(cls),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? null
                        : const LinearGradient(
                        colors: [Colors.red, Color(0xFFFF5252)]),
                    color: isActive ? Colors.red.withValues(alpha: 0.12) : null,
                    borderRadius: BorderRadius.circular(10),
                    border: isActive
                        ? Border.all(
                        color: Colors.red.withValues(alpha: 0.4), width: 1)
                        : null,
                    boxShadow: isActive
                        ? null
                        : [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isActive)
                          Container(
                            width: 8, height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                          )
                        else
                          const Icon(Icons.videocam_rounded,
                              color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Live Now' : 'Go Live',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.red : Colors.white),
                        ),
                      ]),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // More
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: const Icon(Icons.more_horiz_rounded,
                    size: 18, color: AppColors.textMuted),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  TAB 2 — RECORDINGS (Bunny VOD)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRecordingsTab() {
    return Column(children: [
      _buildRecordingsHeader(),
      Expanded(
        child: _recordings.isEmpty
            ? Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎬', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text('No recordings yet',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  const Text(
                      'Recordings appear here after a class ends',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  TextButton(
                      onPressed: _loadData, child: const Text('Refresh')),
                ]))
            : RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _recordings.length,
            itemBuilder: (_, i) => _buildRecordingCard(_recordings[i]),
          ),
        ),
      ),
    ]);
  }

  Widget _buildRecordingsHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Row(children: [
              Icon(Icons.search_rounded, size: 16, color: AppColors.textMuted),
              SizedBox(width: 8),
              Text('Search recordings...',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(11)),
          child: const Icon(Icons.tune_rounded,
              size: 18, color: AppColors.primary),
        ),
      ]),
    );
  }

  Widget _buildRecordingCard(Map<String, dynamic> r) {
    final hlsUrl       = _buildHlsUrl(r);
    final title        = (r['title'] ?? 'Recording').toString();
    final bunnyStatus  = (r['bunny_status'] ?? 'processing').toString();
    final isReady      = bunnyStatus == 'ready' && hlsUrl.isNotEmpty;
    const color        = AppColors.accent;
    const bg           = AppColors.accentSoft;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: [
        // Thumbnail / play area
        GestureDetector(
          onTap: isReady ? () => _openPlayer(hlsUrl, title, isRecording: true) : null,
          child: Container(
            height: 130,
            decoration: const BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Stack(children: [
              Positioned.fill(
                child: CustomPaint(
                  painter:
                  _DiagonalPatternPainter(color.withValues(alpha: 0.06)),
                ),
              ),
              Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎬', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 4),
                      if ((r['subject'] ?? '').toString().isNotEmpty)
                        Text(r['subject'].toString(),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: color)),
                    ]),
              ),

              // Play button or processing indicator
              Center(
                child: isReady
                    ? Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.25),
                          blurRadius: 12),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: color, size: 30),
                )
                    : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Processing...',
                        style: TextStyle(
                            color: Colors.white, fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),

              if ((r['duration'] ?? '').toString().isNotEmpty)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(r['duration'].toString(),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),

              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                      color: isReady ? color : Colors.orange,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    isReady ? 'HD' : 'Processing',
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
            ]),
          ),
        ),

        // Body
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(_formatDateTime(r['created_at']),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
              const Spacer(),
              const Icon(Icons.more_vert_rounded,
                  size: 18, color: AppColors.textMuted),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _recordingBtn(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  color: AppColors.textSecondary,
                  bg: AppColors.background,
                  border: AppColors.border,
                  onTap: () => HapticFeedback.selectionClick(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: isReady
                      ? () => _openPlayer(hlsUrl, title, isRecording: true)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isReady
                          ? LinearGradient(
                          colors: [color, color.withValues(alpha: 0.75)])
                          : null,
                      color: isReady ? null : AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isReady
                                ? Icons.play_circle_rounded
                                : Icons.hourglass_empty_rounded,
                            color: Colors.white, size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isReady ? 'Play Now' : 'Processing...',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ]),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Shared helpers (unchanged)
  // ─────────────────────────────────────────────────────────────────────────
  String _formatDateTime(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return '';
    try {
      final dt     = DateTime.parse(raw.toString()).toLocal();
      final hour   = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]}, $hour:$minute $period';
    } catch (_) {
      return raw.toString();
    }
  }

  Widget _pill(String text, Color bg, Color textColor, {Color? border}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: border != null ? Border.all(color: border, width: 0.5) : null,
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: textColor)),
    );
  }

  Widget _metaChip(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.12), width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: color)),
      ]),
    );
  }

  Widget _recordingBtn({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required Color border,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HLS Video Player Screen (Bunny VOD recordings)
// ─────────────────────────────────────────────────────────────────────────────
class LivePlayerScreen extends StatefulWidget {
  final String hlsUrl;
  final String title;
  final bool isRecording;

  const LivePlayerScreen({
    required this.hlsUrl,
    required this.title,
    this.isRecording = false,
    super.key,
  });

  @override
  State<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends State<LivePlayerScreen> {
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _videoCtrl?.dispose();
      _chewieCtrl?.dispose();
      _videoCtrl =
          VideoPlayerController.networkUrl(Uri.parse(widget.hlsUrl));
      await _videoCtrl!.initialize();
      _chewieCtrl = ChewieController(
        videoPlayerController: _videoCtrl!,
        autoPlay: true,
        isLive: !widget.isRecording,
        allowFullScreen: true,
        looping: false,
        aspectRatio: _videoCtrl!.value.aspectRatio,
      );
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _chewieCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Colors.white))
          : _error != null
          ? Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.red, size: 52),
                const SizedBox(height: 16),
                Text(_error!,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                TextButton(
                    onPressed: _initPlayer,
                    child: const Text('Retry',
                        style: TextStyle(color: Colors.white))),
              ]))
          : Chewie(controller: _chewieCtrl!),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Diagonal pattern painter
// ─────────────────────────────────────────────────────────────────────────────
class _DiagonalPatternPainter extends CustomPainter {
  final Color color;
  const _DiagonalPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1;
    for (double i = -size.height; i < size.width + size.height; i += 24) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), p);
    }
  }

  @override
  bool shouldRepaint(_DiagonalPatternPainter old) => old.color != color;
}