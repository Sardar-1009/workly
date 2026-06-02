import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vacancy.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cache of employer info so we don't fetch the same employer many times.
  final Map<String, Map<String, String>> _employerCache = {};

  /// Fetches employer info (companyName + logo) from employers/{employerId}.
  Future<Map<String, String>> _fetchEmployerInfo(String employerId) async {
    if (_employerCache.containsKey(employerId)) {
      return _employerCache[employerId]!;
    }
    try {
      final doc =
          await _firestore.collection('employers').doc(employerId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final info = {
          'name': (data['companyName'] as String? ?? '').trim(),
          'logo': ((data['logo'] as String? ??
                      data['companyLogo'] as String? ??
                      '') as String)
              .trim(),
        };
        _employerCache[employerId] = info;
        return info;
      }
    } catch (_) {}
    // fallback
    final empty = {'name': '', 'logo': ''};
    _employerCache[employerId] = empty;
    return empty;
  }

  /// Enriches a list of vacancies with employer company data.
  Future<List<Vacancy>> _enrich(List<Vacancy> vacancies) async {
    // Gather unique employer IDs
    final ids = vacancies.map((v) => v.employerId).toSet();
    await Future.wait(ids.map(_fetchEmployerInfo));

    return vacancies.map((v) {
      final info = _employerCache[v.employerId] ?? {'name': '', 'logo': ''};
      return v.withEmployer(
        name: info['name']!,
        logo: info['logo']!,
      );
    }).toList();
  }

  /// Returns a live stream of vacancies, enriched with employer data.
  Stream<List<Vacancy>> getVacanciesStream() {
    return _firestore.collection('vacancies').snapshots().asyncMap(
      (snapshot) async {
        final raw =
            snapshot.docs.map((doc) => Vacancy.fromFirestore(doc)).toList();
        return _enrich(raw);
      },
    );
  }

  /// Returns a one-shot list of vacancies, enriched with employer data.
  Future<List<Vacancy>> getVacancies() async {
    try {
      final snapshot = await _firestore.collection('vacancies').get();
      final raw =
          snapshot.docs.map((doc) => Vacancy.fromFirestore(doc)).toList();
      return _enrich(raw);
    } catch (e) {
      return [];
    }
  }
}
