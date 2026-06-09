import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ScheduleSessionScreen
//
//  Called when tutor taps "Schedule" in LiveScreen AppBar.
//  On success → pops true → LiveScreen refreshes upcoming list.
//
//  API: POST /api/live-sessions   (add this endpoint to your Laravel backend)
//  Body: { title, subject, description, scheduled_at, duration, course_id }
// ─────────────────────────────────────────────────────────────────────────────
class ScheduleSessionScreen extends StatefulWidget {
  const ScheduleSessionScreen({super.key});

  @override
  State<ScheduleSessionScreen> createState() => _ScheduleSessionScreenState();
}

class _ScheduleSessionScreenState extends State<ScheduleSessionScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _titleCtrl      = TextEditingController();
  final _descCtrl       = TextEditingController();

  String? _selectedSubject;
  String  _selectedDuration = '1 hour';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  static const _subjects = [
    'Maths', 'Science', 'English', 'Physics',
    'Chemistry', 'CS', 'History', 'Other',
  ];

  static const _durations = [
    '30 min', '1 hour', '1.5 hrs', '2 hrs',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  // ── Time picker ────────────────────────────────────────────────────────────
  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubject == null) {
      _showSnack('Please select a subject');
      return;
    }
    if (_selectedDate == null) {
      _showSnack('Please select a date');
      return;
    }
    if (_selectedTime == null) {
      _showSnack('Please select a time');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final scheduledAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await ApiService.scheduleSession({
        'title':        _titleCtrl.text.trim(),
        'subject':      _selectedSubject,
        'description':  _descCtrl.text.trim(),
        'scheduled_at': scheduledAt.toIso8601String(),
        'duration':     _selectedDuration,
        'status':       'scheduled',
        'type':         'live',
      });

      if (!mounted) return;
      _showSuccessDialog();

    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to schedule: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.green, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Class Scheduled!',
              style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${_titleCtrl.text.trim()}" has been added to upcoming sessions.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary, height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(true); // pop screen → refresh
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'View Upcoming',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
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

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.border,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 14, color: AppColors.textPrimary),
          ),
        ),
        title: const Text(
          'Schedule a Class',
          style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary, letterSpacing: -0.4,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: [
            _sectionTitle('Class Details'),
            const SizedBox(height: 14),

            // Title
            _fieldLabel('Class Title *'),
            const SizedBox(height: 6),
            _textField(
              controller: _titleCtrl,
              hint: 'e.g. Introduction to Algebra',
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // Subject chips
            _fieldLabel('Subject *'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _subjects.map((s) => _chip(
                label: s,
                selected: _selectedSubject == s,
                onTap: () => setState(() => _selectedSubject = s),
              )).toList(),
            ),
            const SizedBox(height: 16),

            // Description
            _fieldLabel('Description (optional)'),
            const SizedBox(height: 6),
            _textField(
              controller: _descCtrl,
              hint: 'What will students learn in this session?',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            _sectionTitle('Schedule'),
            const SizedBox(height: 14),

            // Date + Time row
            Row(children: [
              Expanded(child: _dateTimeField(
                label: 'Date *',
                value: _selectedDate == null
                    ? null
                    : _formatDate(_selectedDate!),
                icon: Icons.calendar_today_rounded,
                onTap: _pickDate,
              )),
              const SizedBox(width: 12),
              Expanded(child: _dateTimeField(
                label: 'Time *',
                value: _selectedTime == null
                    ? null
                    : _selectedTime!.format(context),
                icon: Icons.access_time_rounded,
                onTap: _pickTime,
              )),
            ]),
            const SizedBox(height: 16),

            // Duration chips
            _fieldLabel('Duration'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _durations.map((d) => _chip(
                label: d,
                selected: _selectedDuration == d,
                onTap: () => setState(() => _selectedDuration = d),
              )).toList(),
            ),
            const SizedBox(height: 32),

            // Submit button
            GestureDetector(
              onTap: _isLoading ? null : _submit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: _isLoading ? null : AppColors.brandGradient,
                  color: _isLoading ? AppColors.border : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isLoading ? null : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2,
                    ),
                  )
                      : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Schedule Class',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Widget helpers — match LiveScreen style exactly
  // ─────────────────────────────────────────────────────────────────────────
  Widget _sectionTitle(String text) => Container(
    padding: const EdgeInsets.only(bottom: 10),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
    ),
    child: Text(text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary)),
  );

  Widget _fieldLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: AppColors.textSecondary));

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
            fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 13, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.border, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.border, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.5), width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 0.5),
          ),
        ),
      );

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: () { HapticFeedback.selectionClick(); onTap(); },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.2 : 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      );

  Widget _dateTimeField({
    required String label,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _fieldLabel(label),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value ?? 'Select',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: value != null
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
        ]),
      );

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}