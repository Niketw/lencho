import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lencho/models/job.dart';

class JobController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Posts a new job with the given details.
  Future<void> postJob({
    required String title,
    required String organisation,
    required String location,
    required String details,
    required double salaryPerWeek,
  }) async {
    final jobData = {
      'title': title,
      'organisation': organisation,
      'location': location,
      'details': details,
      'salaryPerWeek': salaryPerWeek,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await _db.collection('jobs').add(jobData);
      Get.snackbar('Success', 'Job posted successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to post job: $e');
    }
  }

  /// Streams the list of jobs ordered by the most recent.
  Stream<List<Job>> streamJobs() {
    print("Listening to jobs stream...");
    return _db
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print("Snapshot has ${snapshot.docs.length} job documents.");
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['createdAt'] == null) {
              data['createdAt'] = Timestamp.now();
            }
            return Job.fromMap(data, doc.id);
          }).toList();
        });
  }
}
