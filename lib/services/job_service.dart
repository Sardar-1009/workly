import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vacancy.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Vacancy>> getVacanciesStream() {
    return _firestore.collection('vacancies').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Vacancy.fromFirestore(doc)).toList();
    });
  }

  Future<List<Vacancy>> getVacancies() async {
    final snapshot = await _firestore.collection('vacancies').get();
    return snapshot.docs.map((doc) => Vacancy.fromFirestore(doc)).toList();
  }
}
