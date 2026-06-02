import 'package:flutter/material.dart';
import '../models/vacancy.dart';
import '../services/user_job_service.dart';
import '../theme/app_theme.dart';
import 'company_avatar.dart';

class VacancyCard extends StatefulWidget {
  final Vacancy vacancy;

  const VacancyCard({super.key, required this.vacancy});

  @override
  State<VacancyCard> createState() => _VacancyCardState();
}

class _VacancyCardState extends State<VacancyCard> {
  final UserJobService _userJobService = UserJobService();
  bool _isSaved = false;

  // Map work type codes to Russian labels
  static const _workTypeLabels = {
    'full-time': 'Полная занятость',
    'part-time': 'Частичная',
    'contract': 'Контракт',
    'freelance': 'Фриланс',
    'internship': 'Стажировка',
  };

  // Map work types to badge colors
  static const _workTypeColors = {
    'full-time': Color(0xFF6C63FF),
    'part-time': Color(0xFF06D6A0),
    'contract': Color(0xFFF59E0B),
    'freelance': Color(0xFFEC4899),
    'internship': Color(0xFF3B82F6),
  };

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  @override
  void didUpdateWidget(VacancyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vacancy.id != widget.vacancy.id) {
      _isSaved = false;
      _checkIfSaved();
    }
  }

  Future<void> _checkIfSaved() async {
    final isSaved = await _userJobService.isJobSaved(widget.vacancy.id);
    if (mounted) {
      setState(() => _isSaved = isSaved);
    }
  }

  Future<void> _toggleSave() async {
    await _userJobService.toggleSavedJob(widget.vacancy.id);
    if (mounted) {
      setState(() => _isSaved = !_isSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSaved ? '✓ Вакансия сохранена' : 'Вакансия удалена из сохранённых'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Color get _cardAccentColor {
    return _workTypeColors[widget.vacancy.workType.toLowerCase()] ??
        AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final companyInitial = widget.vacancy.company.isNotEmpty
        ? widget.vacancy.company.substring(0, 1).toUpperCase()
        : '?';
    final workTypeLabel = _workTypeLabels[widget.vacancy.workType.toLowerCase()] ??
        widget.vacancy.workType;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header gradient band ───────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _cardAccentColor,
                      _cardAccentColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company row
                    Row(
                      children: [
                        // Logo
                        CompanyAvatar(
                          logoUrl: widget.vacancy.companyLogo,
                          radius: 26,
                          backgroundColor: Colors.white.withOpacity(0.25),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.vacancy.company,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white70,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.vacancy.location,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Save button
                        GestureDetector(
                          onTap: _toggleSave,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ─── Body ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job title
                    Text(
                      widget.vacancy.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1A1B2E),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Salary + Work type row
                    Row(
                      children: [
                        // Salary
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.payments_rounded,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    widget.vacancy.salary,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Work type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _cardAccentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            workTypeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _cardAccentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Skills chips
                    if (widget.vacancy.skills.isNotEmpty) ...[
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: widget.vacancy.skills.take(6).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.07)
                                  : const Color(0xFFF1F2FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : const Color(0xFFDDD9FF),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFC7C4FF)
                                    : AppColors.primaryDark,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Divider
                    Container(
                      height: 1,
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : const Color(0xFFEEF0F8),
                    ),
                    const SizedBox(height: 16),

                    // Description label
                    Text(
                      'Описание',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description body
                    Text(
                      widget.vacancy.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
