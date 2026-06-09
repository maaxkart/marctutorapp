import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfileScreen  — Tutor view  · Light theme · Circular image upload
// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  // In a real app, replace with image_picker logic
  // File? _profileImage;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ──
          SliverAppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            pinned: true,
            titleSpacing: 20,
            title: const Text(
              'My Profile',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_rounded,
                      color: AppColors.primary, size: 15),
                  label: const Text(
                    'Edit',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primarySoft,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(height: 0.5, color: AppColors.border),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(child: _buildProfileHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildVerifiedBanner(),
                const SizedBox(height: 22),
                _buildStatsRow(),
                const SizedBox(height: 28),
                _buildPerformanceSection(),
                const SizedBox(height: 28),
                _buildCoursesSection(),
                const SizedBox(height: 28),
                _buildMenuSection(),
                const SizedBox(height: 20),
                _buildLogoutButton(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── PROFILE HEADER (white card) ────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(children: [
        // ── Avatar with camera button ──
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Outer glow ring
            Container(
              width: 112, height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.18),
                  width: 3,
                ),
              ),
            ),
            // Avatar circle
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.brandGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.30),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'N',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),
              // Uncomment for real image:
              // child: _profileImage != null
              //   ? ClipOval(child: Image.file(_profileImage!, fit: BoxFit.cover))
              //   : Center(child: Text('N', ...)),
            ),
            // Camera button
            Positioned(
              bottom: 0, right: 0,
              child: GestureDetector(
                onTap: _onPickImage,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.surface, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            // Verified tick
            Positioned(
              top: 0, right: 0,
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: const Icon(
                    Icons.verified_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // ── Name ──
        const Text(
          'Nowfal Nazar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 4),

        // ── Specialisation ──
        Text(
          'Mathematics & Physics Educator',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: 12),

        // ── Star rating ──
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ...List.generate(
            5,
                (i) => Icon(
              i < 4
                  ? Icons.star_rounded
                  : Icons.star_half_rounded,
              color: AppColors.warning,
              size: 18,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '4.8',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(1,247 reviews)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ]),

        const SizedBox(height: 14),

        // ── Action buttons ──
        Row(children: [
          Expanded(child: _actionBtn(
            label: 'Share Profile',
            icon: Icons.ios_share_rounded,
            outlined: true,
            onTap: () {},
          )),
          const SizedBox(width: 10),
          Expanded(child: _actionBtn(
            label: 'Go Live',
            icon: Icons.live_tv_rounded,
            outlined: false,
            onTap: () {},
          )),
        ]),
      ]),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required bool outlined,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: outlined ? AppColors.surface : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: outlined ? AppColors.border : AppColors.primary,
            width: outlined ? 1.0 : 0,
          ),
          boxShadow: outlined
              ? null
              : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon,
              color: outlined ? AppColors.textSecondary : Colors.white,
              size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: outlined ? AppColors.textSecondary : Colors.white,
            ),
          ),
        ]),
      ),
    );
  }

  void _onPickImage() {
    // Replace with:
    // final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (picked != null) setState(() => _profileImage = File(picked.path));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add image_picker to pubspec.yaml to enable photo upload'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── VERIFIED BANNER ────────────────────────────────────────────────────────
  Widget _buildVerifiedBanner() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2 * _pulseAnim.value + 0.1),
            width: 1,
          ),
        ),
        child: child,
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.verified_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verified Pro Educator',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Your profile is verified and visible to all students',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
          ],
        )),
        const Icon(Icons.chevron_right_rounded,
            color: AppColors.primary, size: 18),
      ]),
    );
  }

  // ── STATS ROW ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final stats = [
      _StatItem('2,418', 'Students',
          Icons.people_alt_rounded, AppColors.primarySoft, AppColors.primary),
      _StatItem('5',     'Courses',
          Icons.play_lesson_rounded, AppColors.accentSoft, AppColors.accent),
      _StatItem('36h',   'Taught',
          Icons.timer_rounded, const Color(0xFFFFF3E0), AppColors.warning),
      _StatItem('12 🔥', 'Streak',
          Icons.local_fire_department_rounded, AppColors.liveSoft, AppColors.live),
    ];
    return Row(children: stats.asMap().entries.map((e) {
      final isLast = e.key == stats.length - 1;
      final s = e.value;
      return Expanded(child: Container(
        margin: EdgeInsets.only(right: isLast ? 0 : 10),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: s.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(s.icon, color: s.iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(s.value,
            style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(s.label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ]),
      ));
    }).toList());
  }

  // ── PERFORMANCE ───────────────────────────────────────────────────────────
  Widget _buildPerformanceSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Performance'),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _perfCard(
          label: 'Completion rate', value: '89%', fill: 0.89,
          icon: Icons.check_circle_outline_rounded,
          iconBg: AppColors.primarySoft, iconColor: AppColors.primary,
          barColor: AppColors.primary, trend: '+2.1%',
        )),
        const SizedBox(width: 10),
        Expanded(child: _perfCard(
          label: 'Avg watch time', value: '42 min', fill: 0.70,
          icon: Icons.timer_outlined,
          iconBg: AppColors.accentSoft, iconColor: AppColors.accent,
          barColor: AppColors.accent, trend: '+6m',
        )),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _perfCard(
          label: 'Doubt resolution', value: '94%', fill: 0.94,
          icon: Icons.help_outline_rounded,
          iconBg: const Color(0xFFE3ECFF), iconColor: AppColors.info,
          barColor: AppColors.info, trend: '+1.4%',
        )),
        const SizedBox(width: 10),
        Expanded(child: _perfCard(
          label: 'Repeat students', value: '67%', fill: 0.67,
          icon: Icons.repeat_rounded,
          iconBg: AppColors.liveSoft, iconColor: AppColors.live,
          barColor: AppColors.live, trend: '+3%',
        )),
      ]),
    ]);
  }

  Widget _perfCard({
    required String label,
    required String value,
    required double fill,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color barColor,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(trend,
                  style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary, letterSpacing: -0.6,
            )),
        const SizedBox(height: 1),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fill,
            minHeight: 4,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ]),
    );
  }

  // ── COURSES ───────────────────────────────────────────────────────────────
  Widget _buildCoursesSection() {
    final courses = [
      _CourseData('JEE Maths — Complete',    '📐',
          AppColors.primarySoft,       AppColors.primary,
          '840 enrolled · 48 lectures', _Tag.live),
      _CourseData('NEET Physics Batch',       '⚡',
          const Color(0xFFE3ECFF),     AppColors.info,
          '612 enrolled · 36 lectures', _Tag.live),
      _CourseData('JEE Chemistry',            '🧪',
          const Color(0xFFFFF3E0),     AppColors.warning,
          '410 enrolled · 29 lectures', _Tag.recorded),
      _CourseData('Class 11 — Foundation',   '📚',
          AppColors.accentSoft,        AppColors.accent,
          '398 enrolled · 52 lectures', _Tag.live),
      _CourseData('Crash Course — JEE 2025', '🚀',
          AppColors.liveSoft,          AppColors.live,
          '158 enrolled · 18 lectures', _Tag.isNew),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _sectionLabel('My courses'),
        GestureDetector(
          onTap: () {},
          child: Row(children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 14),
            ),
            const SizedBox(width: 5),
            const Text('Add new',
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                )),
          ]),
        ),
      ]),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: courses.asMap().entries.map((e) {
            final isLast = e.key == courses.length - 1;
            return _courseRow(e.value, isLast: isLast);
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _courseRow(_CourseData c, {required bool isLast}) {
    return Column(children: [
      InkWell(
        onTap: () {},
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: c.iconBg,
                  borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(c.icon,
                  style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 3),
                Text(c.meta,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            )),
            const SizedBox(width: 8),
            _tagBadge(c.tag),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 18),
          ]),
        ),
      ),
      if (!isLast)
        const Divider(height: 1, indent: 68, color: AppColors.border),
    ]);
  }

  Widget _tagBadge(_Tag tag) {
    late final String label;
    late final Color bg, fg;
    switch (tag) {
      case _Tag.live:
        label = 'Live'; bg = AppColors.primarySoft; fg = AppColors.primaryDark;
      case _Tag.recorded:
        label = 'Recorded'; bg = const Color(0xFFFFF3E0); fg = const Color(0xFFE65100);
      case _Tag.isNew:
        label = 'New'; bg = AppColors.liveSoft; fg = AppColors.live;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  // ── MENU ──────────────────────────────────────────────────────────────────
  Widget _buildMenuSection() {
    final items = [
      _MenuData(Icons.person_outline_rounded,
          AppColors.primarySoft, AppColors.primary,
          'Edit profile', 'Photo, bio & subjects', ''),
      _MenuData(Icons.notifications_outlined,
          AppColors.liveSoft, AppColors.live,
          'Notifications', 'Manage alerts & reminders', '3'),
      _MenuData(Icons.shield_outlined,
          AppColors.accentSoft, AppColors.accent,
          'Privacy & security', 'Data, permissions', ''),
      _MenuData(Icons.help_outline_rounded,
          const Color(0xFFFFF3E0), AppColors.warning,
          'Help & support', 'FAQs, contact us', ''),
      _MenuData(Icons.info_outline_rounded,
          AppColors.background, AppColors.textMuted,
          'About', 'Version 2.1.0', ''),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Account'),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return _menuRow(e.value, isLast: isLast);
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _menuRow(_MenuData m, {required bool isLast}) {
    return Column(children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
              color: m.iconBg, borderRadius: BorderRadius.circular(11)),
          child: Icon(m.icon, color: m.iconColor, size: 18),
        ),
        title: Text(m.label,
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            )),
        subtitle: Text(m.sub,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (m.badge.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.live,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(m.badge,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 18),
        ]),
      ),
      if (!isLast) const Divider(height: 1, indent: 68, color: AppColors.border),
    ]);
  }

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.liveSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.live.withOpacity(0.25), width: 0.5),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout_rounded, color: AppColors.live, size: 17),
          SizedBox(width: 8),
          Text('Log out',
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.live,
              )),
        ]),
      ),
    );
  }

  // ── helper ────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w700,
      color: AppColors.textMuted, letterSpacing: 1.0,
    ),
  );
}

// ─── Supporting data classes ───────────────────────────────────────────────────
enum _Tag { live, recorded, isNew }

class _StatItem {
  final String value, label;
  final IconData icon;
  final Color iconBg, iconColor;
  const _StatItem(this.value, this.label, this.icon, this.iconBg, this.iconColor);
}

class _CourseData {
  final String name, icon, meta;
  final Color iconBg, iconColor;
  final _Tag tag;
  const _CourseData(this.name, this.icon, this.iconBg, this.iconColor,
      this.meta, this.tag);
}

class _MenuData {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label, sub, badge;
  const _MenuData(this.icon, this.iconBg, this.iconColor, this.label,
      this.sub, this.badge);
}