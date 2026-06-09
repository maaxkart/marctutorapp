import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final TextEditingController _search = TextEditingController();
  int _selectedFilter = 0;

  final _filters = ['All', 'Active', 'Inactive', 'Top Performers'];

  final List<Map<String, dynamic>> _students = [
    {
      'name': 'Ananya Sharma',
      'course': 'JEE Maths',
      'progress': 87,
      'lastSeen': '2h ago',
      'sessions': 18,
      'doubt': 3,
      'isActive': true,
      'gradient': [Color(0xFF5A4FCF), Color(0xFF7B6EE8)],
    },
    {
      'name': 'Rahul Verma',
      'course': 'NEET Physics',
      'progress': 74,
      'lastSeen': '1d ago',
      'sessions': 14,
      'doubt': 1,
      'isActive': true,
      'gradient': [Color(0xFF08BD80), Color(0xFF04A574)],
    },
    {
      'name': 'Priya Menon',
      'course': 'JEE Maths',
      'progress': 69,
      'lastSeen': '5h ago',
      'sessions': 12,
      'doubt': 5,
      'isActive': true,
      'gradient': [Color(0xFFE53935), Color(0xFFFF5252)],
    },
    {
      'name': 'Arjun Patel',
      'course': 'JEE Chemistry',
      'progress': 52,
      'lastSeen': '3d ago',
      'sessions': 9,
      'doubt': 0,
      'isActive': false,
      'gradient': [Color(0xFFFF6D00), Color(0xFFFFAB40)],
    },
    {
      'name': 'Sneha Rao',
      'course': 'NEET Biology',
      'progress': 91,
      'lastSeen': '30m ago',
      'sessions': 22,
      'doubt': 2,
      'isActive': true,
      'gradient': [Color(0xFF2979FF), Color(0xFF448AFF)],
    },
    {
      'name': 'Vikram Singh',
      'course': 'JEE Maths',
      'progress': 44,
      'lastSeen': '7d ago',
      'sessions': 6,
      'doubt': 0,
      'isActive': false,
      'gradient': [Color(0xFF6D4C41), Color(0xFFA1887F)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('My Students'),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.sort_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Students'),
            Tab(text: 'Doubts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildStudentsTab(),
          _buildDoubtsTab(),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Search
      Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: TextField(
          controller: _search,
          decoration: InputDecoration(
            hintText: 'Search students...',
            prefixIcon:
                const Icon(Icons.search_rounded, color: AppColors.textMuted),
            fillColor: AppColors.background,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
      // Filter chips
      Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Row(
          children: _filters.asMap().entries.map((e) {
            final sel = _selectedFilter == e.key;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: sel ? AppColors.brandGradient : null,
                  color: sel ? null : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel ? Colors.transparent : AppColors.border),
                ),
                child: Text(e.value,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppColors.textSecondary)),
              ),
            );
          }).toList(),
        ),
      ),

      // Summary banner
      Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          const Icon(Icons.school_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              children: [
                TextSpan(
                    text: '2,418 ',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                TextSpan(text: 'total enrolled across '),
                TextSpan(
                    text: '5 courses',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ],
            ),
          ),
        ]),
      ),

      const SizedBox(height: 8),

      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 32),
          itemCount: _students.length,
          itemBuilder: (_, i) => _buildStudentCard(_students[i]),
        ),
      ),
    ]);
  }

  Widget _buildStudentCard(Map<String, dynamic> s) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: s['gradient'] as List<Color>,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: Text((s['name'] as String)[0],
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(children: [
              Text(s['name'] as String,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s['isActive'] == true
                      ? AppColors.success
                      : AppColors.textMuted,
                ),
              ),
            ]),
            const SizedBox(height: 3),
            Text('${s['course']} · ${s['sessions']} sessions',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 10),
            Row(children: [
              // Progress
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    const Text('Progress',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textMuted)),
                    Text('${s['progress']}%',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (s['progress'] as int) / 100,
                      minHeight: 5,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 14),
              // Doubts badge
              if ((s['doubt'] as int) > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.liveSoft,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                      '${s['doubt']} doubt${(s['doubt'] as int) > 1 ? 's' : ''}',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.live)),
                ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.access_time_rounded,
                  size: 11, color: AppColors.textMuted),
              const SizedBox(width: 3),
              Text('Last seen ${s['lastSeen']}',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
              const Spacer(),
              GestureDetector(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text('Message',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildDoubtsTab() {
    final doubts = [
      {
        'student': 'Ananya Sharma',
        'subject': 'Mathematics',
        'question':
            'How do we apply L\'Hôpital\'s rule when the limit is of ∞/∞ form? Can you show with an example?',
        'time': '10 min ago',
        'isNew': true,
        'gradient': [Color(0xFF5A4FCF), Color(0xFF7B6EE8)],
      },
      {
        'student': 'Priya Menon',
        'subject': 'Mathematics',
        'question':
            'Sir, in the integration by parts problem from yesterday\'s class, why did we choose u = ln(x)?',
        'time': '1h ago',
        'isNew': true,
        'gradient': [Color(0xFFE53935), Color(0xFFFF5252)],
      },
      {
        'student': 'Sneha Rao',
        'subject': 'Physics',
        'question':
            'What is the difference between conservative and non-conservative forces with real-life examples?',
        'time': '2h ago',
        'isNew': false,
        'gradient': [Color(0xFF2979FF), Color(0xFF448AFF)],
      },
      {
        'student': 'Rahul Verma',
        'subject': 'Physics',
        'question':
            'In the projectile problem from session 14, the answer doesn\'t match my calculation.',
        'time': '1d ago',
        'isNew': false,
        'gradient': [Color(0xFF08BD80), Color(0xFF04A574)],
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: doubts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final d = doubts[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: d['isNew'] == true
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.border,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: d['gradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text((d['student'] as String)[0],
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(d['student'] as String,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text('${d['subject']} · ${d['time']}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                ]),
              ),
              if (d['isNew'] == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('New',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
            ]),
            const SizedBox(height: 10),
            Text(d['question'] as String,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('View Full',
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
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Center(
                    child: Text('Answer Now',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ),
            ]),
          ]),
        );
      },
    );
  }
}
