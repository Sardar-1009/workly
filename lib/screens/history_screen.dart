import 'package:flutter/material.dart';
import '../models/vacancy.dart';
import '../data/mock_vacancies.dart';
import '../services/user_job_service.dart';
import '../services/analytics_service.dart'; // To log Accepted status

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserJobService _userJobService = UserJobService();
  final List<Vacancy> _allVacancies = MockVacancyService.getVacancies();

  // Data
  List<Vacancy> _viewed = [];
  List<Vacancy> _saved = [];
  Map<String, ApplicationStatus> _appliedMap = {};
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
    final appliedMap = await _userJobService.getAppliedJobsMap();

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

  Future<void> _updateStatus(String vacancyId, ApplicationStatus status) async {
    await _userJobService.updateApplicationStatus(vacancyId, status);

    // Log "Accepted" event if status is invited
    if (status == ApplicationStatus.invited) {
      await AnalyticsService().logEvent(AnalyticsEventType.accepted);
    }

    _loadData(); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Applied'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_viewed, 'No viewed jobs yet'),
                _buildAppliedList(),
                _buildList(_saved, 'No saved jobs', isSavedTab: true),
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
            leading: CircleAvatar(child: Text(vacancy.company[0])),
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

  Widget _buildAppliedList() {
    if (_applied.isEmpty)
      return const Center(child: Text('No applications sent'));

    return ListView.builder(
      itemCount: _applied.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final vacancy = _applied[index];
        final status = _appliedMap[vacancy.id] ?? ApplicationStatus.sent;

        Color statusColor = Colors.grey;
        String statusText = 'Sent';
        if (status == ApplicationStatus.invited) {
          statusColor = Colors.green;
          statusText = 'Invited';
        } else if (status == ApplicationStatus.rejected) {
          statusColor = Colors.red;
          statusText = 'Rejected';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(child: Text(vacancy.company[0])),
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
                          _updateStatus(vacancy.id, ApplicationStatus.invited),
                      child: const Text('Mark Invited'),
                    ),
                    TextButton(
                      onPressed: () =>
                          _updateStatus(vacancy.id, ApplicationStatus.rejected),
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
