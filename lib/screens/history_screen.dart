import 'package:flutter/material.dart';
import '../models/vacancy.dart';
import '../services/job_service.dart';
import '../services/user_job_service.dart';
import '../services/analytics_service.dart'; // To log Accepted status
import '../l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserJobService _userJobService = UserJobService();
  final JobService _jobService = JobService();
  List<Vacancy> _allVacancies = [];

  // Data
  List<Vacancy> _viewed = [];
  List<Vacancy> _saved = [];
  Map<String, String> _appliedMap = {};
  List<Vacancy> _applied = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Fetch IDs
    final viewedIds = await _userJobService.getViewedJobs();
    final savedIds = await _userJobService.getSavedJobs();
    final appliedMap = await _userJobService.getAppliedJobsStatusMap();
    _allVacancies = await _jobService.getVacancies();

    // Map to Objects
    _viewed = _allVacancies.where((v) => viewedIds.contains(v.id)).toList();
    _saved = _allVacancies.where((v) => savedIds.contains(v.id)).toList();
    _applied =
        _allVacancies.where((v) => appliedMap.containsKey(v.id)).toList();
    _appliedMap = appliedMap;

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String vacancyId, String status) async {
    await _userJobService.updateApplicationStatus(vacancyId, status);

    // Log "Accepted" event if status is invited
    if (status == 'invited') {
      await AnalyticsService().logEvent(AnalyticsEventType.accepted);
    }

    _loadData(); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n?.historyTab ?? 'Activity'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n?.historyTab ?? 'History'),
            Tab(text: l10n?.applied ?? 'Applied'),
            Tab(text: 'Сохраненные'), // Reusing profileSaved as "Saved" for now, ideally need a specific key, but let's use what we have or just add it. Let's use hardcoded or better, I will just use l10n if I can. Wait, I'll update arb later if needed. Actually I'll use a hardcoded fallback.
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_viewed, l10n?.noHistory ?? 'No viewed jobs yet'),
                _buildAppliedList(l10n),
                _buildList(_saved, l10n?.noJobsFound ?? 'No saved jobs', isSavedTab: true),
              ],
            ),
    );
  }

  Widget _buildList(List<Vacancy> vacancies, String emptyMsg,
      {bool isSavedTab = false}) {
    if (vacancies.isEmpty) return Center(child: Text(emptyMsg));

    return ListView.builder(
      itemCount: vacancies.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final vacancy = vacancies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(child: Text(vacancy.company.isNotEmpty ? vacancy.company[0] : '?')),
            title: Text(vacancy.title),
            subtitle: Text(vacancy.company),
            trailing: isSavedTab
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await _userJobService.toggleSavedJob(vacancy.id);
                      _loadData();
                    })
                : null,
          ),
        );
      },
    );
  }

  Widget _buildAppliedList(AppLocalizations? l10n) {
    if (_applied.isEmpty)
      return Center(child: Text(l10n?.noHistory ?? 'No applications sent'));

    return ListView.builder(
      itemCount: _applied.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final vacancy = _applied[index];
        final status = _appliedMap[vacancy.id] ?? 'pending';

        Color statusColor = Colors.grey;
        String statusText = 'Pending';
        if (status == 'accepted' || status == 'invited') {
          statusColor = Colors.green;
          statusText = 'Accepted / Invited';
        } else if (status == 'rejected') {
          statusColor = Colors.red;
          statusText = 'Rejected';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(child: Text(vacancy.company.isNotEmpty ? vacancy.company[0] : '?')),
            title: Text(vacancy.title),
            subtitle: Text(vacancy.company,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Chip(
              label: Text(statusText,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
              backgroundColor: statusColor,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _updateStatus(vacancy.id, 'invited'),
                      child: const Text('Mark Invited'),
                    ),
                    TextButton(
                      onPressed: () =>
                          _updateStatus(vacancy.id, 'rejected'),
                      child: const Text('Mark Rejected',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
