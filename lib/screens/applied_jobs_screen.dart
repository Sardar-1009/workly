import 'package:flutter/material.dart';
import '../models/vacancy.dart';
import '../data/mock_vacancies.dart';
import '../services/user_job_service.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  final UserJobService _userJobService = UserJobService();
  List<Vacancy> _appliedVacancies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppliedJobs();
  }

  Future<void> _loadAppliedJobs() async {
    final appliedIds = await _userJobService.getAppliedJobIds();
    final allVacancies = MockVacancyService.getVacancies();

    setState(() {
      _appliedVacancies =
          allVacancies.where((v) => appliedIds.contains(v.id)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applied Jobs'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appliedVacancies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No applications yet',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _appliedVacancies.length,
                  itemBuilder: (context, index) {
                    final vacancy = _appliedVacancies[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Text(vacancy.company[0]),
                        ),
                        title: Text(
                          vacancy.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(vacancy.company),
                        trailing:
                            const Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  },
                ),
    );
  }
}
