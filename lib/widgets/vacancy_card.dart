import 'package:flutter/material.dart';
import '../models/vacancy.dart';
import '../services/user_job_service.dart';

class VacancyCard extends StatefulWidget {
  final Vacancy vacancy;

  const VacancyCard({super.key, required this.vacancy});

  @override
  State<VacancyCard> createState() => _VacancyCardState();
}

class _VacancyCardState extends State<VacancyCard> {
  final UserJobService _userJobService = UserJobService();
  bool _isSaved = false;

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
          content: Text(_isSaved ? 'Job Saved' : 'Job Removed from Saved'),
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest,
          ],
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company and Location + Favorite Button
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.vacancy.company.substring(0, 1),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vacancy.company,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.vacancy.location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: _toggleSave,
                    icon: Icon(
                      _isSaved ? Icons.favorite : Icons.favorite_border,
                      color: _isSaved ? Colors.red : Colors.grey,
                    ))
              ],
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              widget.vacancy.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            // Salary
            Text(
              widget.vacancy.salaryRange,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.vacancy.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor:
                      theme.colorScheme.secondaryContainer.withOpacity(0.5),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Extra Info (Format/Experience)
            Wrap(
              spacing: 8,
              children: [
                _buildBadge(widget.vacancy.workFormat,
                    Colors.blue.withOpacity(0.1), Colors.blue),
                _buildBadge(widget.vacancy.experience,
                    Colors.orange.withOpacity(0.1), Colors.orange),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            // Description
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.vacancy.description,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style:
              TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
