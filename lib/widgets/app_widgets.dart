import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────
//  LiveBadge
// ─────────────────────────────────────────
class LiveBadge extends StatefulWidget {
  final bool isLive;
  const LiveBadge({super.key, this.isLive = true});

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.textMuted.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text('SCHEDULED',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.8)),
      );
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.live,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
                color: AppColors.live.withOpacity(0.4 * _anim.value),
                blurRadius: 8,
                spreadRadius: 1),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(_anim.value),
                  shape: BoxShape.circle)),
          const SizedBox(width: 5),
          const Text('LIVE',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  StatCard  (dashboard stats)
// ─────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String? delta;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          if (delta != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(delta!,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
        ]),
        const SizedBox(height: 12),
        Text(value,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ]),
    );
  }
}

// ─────────────────────────────────────────
//  ClassCard  (live / upcoming class)
// ─────────────────────────────────────────
class ClassCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool compact;
  final VoidCallback? onTap;

  const ClassCard(
      {super.key, required this.data, this.compact = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isLive = data['isLive'] == true;
    final Color subjectColor = data['color'] as Color? ?? AppColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: compact ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLive ? AppColors.live.withOpacity(0.3) : AppColors.border,
            width: isLive ? 1.5 : 1,
          ),
          boxShadow: isLive
              ? [
                  BoxShadow(
                      color: AppColors.live.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top colour bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: subjectColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                LiveBadge(isLive: isLive),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(data['subject'] as String,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: subjectColor)),
                ),
              ]),
              const SizedBox(height: 10),
              Text(data['title'] as String,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.access_time_rounded,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(data['time'] as String,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(width: 14),
                const Icon(Icons.people_alt_rounded,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('${data['enrolled']} enrolled',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ]),
              if (isLive) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      gradient: AppColors.liveGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text('Go to Live Class',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text('Manage',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('Start Now',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ]),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  StudentTile
// ─────────────────────────────────────────
class StudentTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const StudentTile({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data['gradient'] as List<Color>,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                (data['name'] as String)[0],
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'] as String,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('${data['course']} · ${data['progress']}% done',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          // Progress bar
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${data['progress']}%',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            SizedBox(
              width: 64,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (data['progress'] as int) / 100,
                  minHeight: 5,
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SectionHeader
// ─────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader(
      {super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  QuickActionButton
// ─────────────────────────────────────────
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 7),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

// ─────────────────────────────────────────
//  EarningsBar
// ─────────────────────────────────────────
class EarningsBar extends StatelessWidget {
  final String month;
  final double amount;
  final double maxAmount;
  final bool isHighlight;

  const EarningsBar({
    super.key,
    required this.month,
    required this.amount,
    required this.maxAmount,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = amount / maxAmount;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isHighlight)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('₹${(amount / 1000).toStringAsFixed(0)}k',
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: ratio.clamp(0.05, 1.0),
              child: Container(
                width: 28,
                decoration: BoxDecoration(
                  gradient: isHighlight
                      ? AppColors.brandGradient
                      : const LinearGradient(
                          colors: [Color(0xFFE8E8F0), Color(0xFFDDDDEC)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(month,
            style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isHighlight ? FontWeight.w700 : FontWeight.w400,
                color: isHighlight
                    ? AppColors.primary
                    : AppColors.textMuted)),
      ],
    );
  }
}
