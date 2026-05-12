import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/network/api_client.dart';
import '../complaints/domain/complaint.dart';
import '../complaints/data/complaint_repository.dart';

class SyncManager {
  SyncManager({
    ApiClient? apiClient,
    ComplaintRepository? repository,
  })  : _apiClient = apiClient ?? ApiClient(),
        _repository = repository ?? ComplaintRepository();

  final ApiClient _apiClient;
  final ComplaintRepository _repository;

  Future<void> syncPendingComplaints() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return;
    }

    final complaints = await _repository.getPendingComplaints();
    for (final complaint in complaints) {
      await _syncComplaint(complaint);
    }
  }

  Future<void> _syncComplaint(Complaint complaint) async {
      final response = await _apiClient.submitComplaint({
        'citizen_name': complaint.citizenName,
        'citizen_contact': complaint.citizenContact,
        'subject': complaint.subject,
        'description': complaint.description,
        'source': 'mobile-offline-sync',
        'latitude': complaint.latitude,
        'longitude': complaint.longitude,
      });

      await _repository.markSynced(complaint.localId, response['id'] as int);
  }
}
