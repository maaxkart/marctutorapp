import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

// ─── Light-mode color overrides (drop into app_theme.dart or use here) ────────
// Replace AppColors references below, or patch AppColors to be light-aware.

class LightColors {
  static const Color background   = Color(0xFFF5F4F0);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceAlt   = Color(0xFFF0EEE9);
  static const Color border       = Color(0xFFE4E2DC);
  static const Color borderStrong = Color(0xFFCDCBC4);
  static const Color textPrimary  = Color(0xFF1A1916);
  static const Color textSecondary= Color(0xFF6B6962);
  static const Color textMuted    = Color(0xFF9B9890);
  static const Color primary      = Color(0xFF08BD80);   // brand violet
  static const Color accent       = Color(0xFF08BD80);   // emerald
  static const Color live         = Color(0xFFE53935);
  static const Color warning      = Color(0xFFFFB300);
  static const Color error        = Color(0xFFE53935);
  static const Color orange       = Color(0xFFFF6D00);
  static const Color blue         = Color(0xFF2979FF);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF08BD80), Color(0xFF08BD80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A1916), Color(0xFF2D2B26)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── HomeScreen ────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _classes = [
    {
      'title': 'Calculus: Limits & Continuity — Batch 3',
      'subject': 'Mathematics',
      'time': 'Live Now · 45 min left',
      'enrolled': 128,
      'isLive': true,
      'color': LightColors.accent,
      'tag': 'LIVE',
    },
    {
      'title': 'Newton\'s Laws of Motion — Complete Revision',
      'subject': 'Physics',
      'time': 'Today · 6:00 PM',
      'enrolled': 94,
      'isLive': false,
      'color': LightColors.blue,
      'tag': 'UPCOMING',
    },
    {
      'title': 'Organic Chemistry — Nomenclature Session',
      'subject': 'Chemistry',
      'time': 'Tomorrow · 10:00 AM',
      'enrolled': 76,
      'isLive': false,
      'color': LightColors.orange,
      'tag': 'SCHEDULED',
    },
  ];

  final List<Map<String, dynamic>> _topStudents = [
    {
      'name': 'Ananya Sharma',
      'course': 'JEE Maths',
      'progress': 87,
      'initial': 'A',
      'color': LightColors.primary,
    },
    {
      'name': 'Rahul Verma',
      'course': 'NEET Physics',
      'progress': 74,
      'initial': 'R',
      'color': LightColors.accent,
    },
    {
      'name': 'Priya Menon',
      'course': 'JEE Chemistry',
      'progress': 69,
      'initial': 'P',
      'color': LightColors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: LightColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroBanner(),
                _buildStatsRow(),
                _buildQuickActions(),
                _buildSectionLabel('Your Classes', onAction: () {}),
                ..._classes.map((c) => _buildClassCard(c)),
                _buildSectionLabel('Top Students', onAction: () {}),
                _buildTopStudentsCard(),
                _buildRatingCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: LightColors.surface,
      expandedHeight: 0,
      toolbarHeight: 68,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: LightColors.border,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: LightColors.surface,
            border: Border(
              bottom: BorderSide(color: LightColors.border, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
          child: Row(
            children: [
              // Logo
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LightColors.brandGradient,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Center(
                  child: Text('T',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5)),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Good morning, Nowfal 👋',
                        style: TextStyle(
                            fontSize: 12,
                            color: LightColors.textMuted,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1)),
                    const Text('Your Dashboard',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: LightColors.textPrimary,
                            letterSpacing: -0.4)),
                  ],
                ),
              ),
              // Search
              _appBarIcon(Icons.search_rounded),
              const SizedBox(width: 6),
              // Notification
              Stack(children: [
                _appBarIcon(Icons.notifications_none_rounded),
                Positioned(
                  top: 9,
                  right: 10,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, __) => Opacity(
                      opacity: _pulseAnimation.value,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: LightColors.live, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(width: 6),
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LightColors.brandGradient,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Center(
                  child: Text('N',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarIcon(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: LightColors.surfaceAlt,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: LightColors.border, width: 0.5),
      ),
      child: Icon(icon, color: LightColors.textPrimary, size: 18),
    );
  }

  // ─── Hero Banner ──────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: LightColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -40,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LightColors.primary.withOpacity(0.18),
              ),
            ),
          ),
          Positioned(
            left: -15,
            bottom: -15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LightColors.accent.withOpacity(0.12),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Live badge
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (_, __) => Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: LightColors.live.withOpacity(
                                    _pulseAnimation.value),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: LightColors.live.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('CLASS IN PROGRESS',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFFF6B6B),
                                    letterSpacing: 1.0)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text('128 students\nwatching live',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -0.8)),
                      const SizedBox(height: 8),
                      Text('Calculus: Limits & Continuity',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1)),
                      const SizedBox(height: 18),
                      // Resume button
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 11),
                          decoration: BoxDecoration(
                            color: LightColors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videocam_rounded,
                                  color: Colors.white, size: 15),
                              SizedBox(width: 7),
                              Text('Resume Class',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.1)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Rating widget
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.1), width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: LightColors.primary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_graph_rounded,
                            color: LightColors.primary, size: 20),
                      ),
                      const SizedBox(height: 10),
                      const Text('4.8',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5)),
                      const Icon(Icons.star_rounded,
                          color: LightColors.warning, size: 14),
                      const SizedBox(height: 2),
                      Text('Rating',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.35),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final stats = [
      {
        'value': '2,418',
        'label': 'Students',
        'icon': Icons.school_rounded,
        'color': LightColors.primary,
        'bg': const Color(0xFFEEECFD),
        'delta': '+12%',
      },
      {
        'value': '₹38.4k',
        'label': 'Revenue',
        'icon': Icons.account_balance_wallet_rounded,
        'color': LightColors.accent,
        'bg': const Color(0xFFE0F8EF),
        'delta': '+8%',
      },
      {
        'value': '14',
        'label': 'Classes',
        'icon': Icons.video_camera_front_rounded,
        'color': LightColors.orange,
        'bg': const Color(0xFFFFF0E6),
        'delta': null,
      },
      {
        'value': '92%',
        'label': 'Attendance',
        'icon': Icons.how_to_reg_rounded,
        'color': LightColors.blue,
        'bg': const Color(0xFFE6EFFF),
        'delta': null,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: stats
            .map((s) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: s == stats.last ? 0 : 10),
            child: _buildStatTile(s),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildStatTile(Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: LightColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: s['bg'] as Color,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(s['icon'] as IconData,
                color: s['color'] as Color, size: 15),
          ),
          const SizedBox(height: 10),
          Text(s['value'] as String,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: LightColors.textPrimary,
                  letterSpacing: -0.4)),
          const SizedBox(height: 2),
          Text(s['label'] as String,
              style: const TextStyle(
                  fontSize: 10,
                  color: LightColors.textMuted,
                  fontWeight: FontWeight.w500)),
          if (s['delta'] != null) ...[
            const SizedBox(height: 4),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F8EF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(s['delta'] as String,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: LightColors.accent)),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Quick Actions ────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.add_rounded,
        'label': 'New Class',
        'color': LightColors.primary,
        'bg': const Color(0xFFEEECFD),
      },
      {
        'icon': Icons.upload_rounded,
        'label': 'Upload',
        'color': LightColors.accent,
        'bg': const Color(0xFFE0F8EF),
      },
      {
        'icon': Icons.poll_outlined,
        'label': 'Poll',
        'color': LightColors.orange,
        'bg': const Color(0xFFFFF0E6),
      },
      {
        'icon': Icons.assignment_outlined,
        'label': 'Homework',
        'color': LightColors.blue,
        'bg': const Color(0xFFE6EFFF),
      },
      {
        'icon': Icons.campaign_rounded,
        'label': 'Announce',
        'color': LightColors.live,
        'bg': const Color(0xFFFFEBEB),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Quick Actions'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions
                .map((a) => _buildActionButton(a))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> a) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: a['bg'] as Color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: (a['color'] as Color).withOpacity(0.18), width: 0.5),
            ),
            child: Icon(a['icon'] as IconData,
                color: a['color'] as Color, size: 22),
          ),
          const SizedBox(height: 7),
          Text(a['label'] as String,
              style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: LightColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ─── Section Label ────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String title, {VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: LightColors.textPrimary,
                  letterSpacing: -0.3)),
          const Spacer(),
          if (onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LightColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: LightColors.border, width: 0.5),
                ),
                child: const Text('View All',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LightColors.textSecondary)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: LightColors.textPrimary,
            letterSpacing: -0.3));
  }

  // ─── Class Card ───────────────────────────────────────────────────────────

  Widget _buildClassCard(Map<String, dynamic> c) {
    final color = c['color'] as Color;
    final isLive = c['isLive'] as bool;

    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: LightColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isLive ? color.withOpacity(0.35) : LightColors.border,
            width: isLive ? 1.5 : 0.5,
          ),
          boxShadow: isLive
              ? [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color strip + icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _subjectIcon(c['subject'] as String),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isLive
                              ? LightColors.live.withOpacity(0.1)
                              : LightColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(c['tag'] as String,
                            style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: isLive
                                    ? LightColors.live
                                    : LightColors.textMuted,
                                letterSpacing: 0.8)),
                      ),
                      const SizedBox(width: 6),
                      Text(c['subject'] as String,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: LightColors.textMuted)),
                    ]),
                    const SizedBox(height: 5),
                    Text(c['title'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: LightColors.textPrimary,
                            letterSpacing: -0.2,
                            height: 1.3)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.schedule_rounded,
                          size: 12, color: LightColors.textMuted),
                      const SizedBox(width: 4),
                      Text(c['time'] as String,
                          style: const TextStyle(
                              fontSize: 11,
                              color: LightColors.textMuted,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 10),
                      Icon(Icons.people_alt_rounded,
                          size: 12, color: LightColors.textMuted),
                      const SizedBox(width: 4),
                      Text('${c['enrolled']}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: LightColors.textMuted,
                              fontWeight: FontWeight.w500)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  isLive
                      ? Icons.play_arrow_rounded
                      : Icons.chevron_right_rounded,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _subjectIcon(String subject) {
    switch (subject) {
      case 'Mathematics':
        return Icons.functions_rounded;
      case 'Physics':
        return Icons.bolt_rounded;
      case 'Chemistry':
        return Icons.science_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  // ─── Top Students ─────────────────────────────────────────────────────────

  Widget _buildTopStudentsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: LightColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LightColors.border, width: 0.5),
      ),
      child: Column(
        children: _topStudents.asMap().entries.map((e) {
          final index = e.key;
          final s = e.value;
          final isLast = index == _topStudents.length - 1;
          return _buildStudentTile(s, index + 1, !isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildStudentTile(
      Map<String, dynamic> s, int rank, bool showDivider) {
    final color = s['color'] as Color;
    final progress = s['progress'] as int;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Rank
              Container(
                width: 22,
                alignment: Alignment.center,
                child: Text('#$rank',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: LightColors.textMuted)),
              ),
              const SizedBox(width: 10),
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(s['initial'] as String,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: color)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['name'] as String,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: LightColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(s['course'] as String,
                        style: const TextStyle(
                            fontSize: 11,
                            color: LightColors.textMuted,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Stack(children: [
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: LightColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress / 100,
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('$progress%',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ],
          ),
        ),
        if (showDivider)
          Divider(
              height: 0.5,
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
              color: LightColors.border),
      ],
    );
  }

  // ─── Rating Card ──────────────────────────────────────────────────────────

  Widget _buildRatingCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LightColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LightColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Your Rating',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: LightColors.textPrimary,
                      letterSpacing: -0.3)),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E6),
                  borderRadius: BorderRadius.circular(8),
                  border:
                  Border.all(color: LightColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: LightColors.warning, size: 13),
                    const SizedBox(width: 4),
                    const Text('Top Educator',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8A6200))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('4.8',
                    style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: LightColors.textPrimary,
                        letterSpacing: -2,
                        height: 1)),
                const SizedBox(height: 8),
                Row(children: List.generate(5, (i) {
                  return Icon(
                    Icons.star_rounded,
                    color: i < 4
                        ? LightColors.warning
                        : LightColors.warning.withOpacity(0.35),
                    size: 16,
                  );
                })),
                const SizedBox(height: 4),
                const Text('1,247 reviews',
                    style: TextStyle(
                        fontSize: 11,
                        color: LightColors.textMuted,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _ratingBarLight('5★', 0.72, LightColors.primary),
                  _ratingBarLight('4★', 0.18, LightColors.accent),
                  _ratingBarLight('3★', 0.06, LightColors.textMuted),
                  _ratingBarLight('2★', 0.03, LightColors.orange),
                  _ratingBarLight('1★', 0.01, LightColors.live),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _ratingBarLight(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        SizedBox(
          width: 22,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: LightColors.textMuted,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(children: [
              Container(
                height: 7,
                color: LightColors.surfaceAlt,
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text('${(value * 100).round()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 10,
                  color: LightColors.textMuted,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}