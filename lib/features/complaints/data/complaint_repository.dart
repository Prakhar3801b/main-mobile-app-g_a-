import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/app_database.dart';
import '../domain/complaint.dart';

class ComplaintRepository {
  final AppDatabase _database = AppDatabase.instance;
  final ApiClient _apiClient = ApiClient();
  final Uuid _uuid = const Uuid();
  static final List<Complaint> _webComplaints = [];

  Future<void> addComplaint({
    required String citizenName,
    required String citizenContact,
    required String subject,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    final complaint = Complaint(
      localId: _uuid.v4(),
      citizenName: citizenName,
      citizenContact: citizenContact,
      subject: subject,
      description: description,
      queueStatus: 'pending',
      createdAt: DateTime.now().toIso8601String(),
      latitude: latitude,
      longitude: longitude,
      status: 'registered',
    );

    if (kIsWeb) {
      _webComplaints.insert(0, complaint);
      return;
    }

    final db = await _database.database;
    await db.insert('complaints', complaint.toMap());
    await db.insert('sync_queue', {
      'complaint_local_id': complaint.localId,
      'action': 'create',
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Complaint>> getComplaints() async {
    if (kIsWeb) {
      return List<Complaint>.from(_webComplaints);
    }

    final db = await _database.database;
    final maps = await db.query('complaints', orderBy: 'created_at DESC');
    return maps.map(Complaint.fromMap).toList();
  }

  Future<Map<String, int>> getStatusCounts() async {
    final complaints = await getComplaints();
    return {
      'pending': complaints.where((item) => item.queueStatus == 'pending').length,
      'synced': complaints.where((item) => item.queueStatus == 'synced').length,
      'registered': complaints.where((item) => item.remoteId != null).length,
    };
  }

  Future<void> markSynced(String localId, int remoteId) async {
    if (kIsWeb) {
      final index = _webComplaints.indexWhere((item) => item.localId == localId);
      if (index != -1) {
        _webComplaints[index] = _webComplaints[index].copyWith(
          queueStatus: 'synced',
          remoteId: remoteId,
          status: 'posted',
        );
      }
      return;
    }

    final db = await _database.database;
    await db.update(
      'complaints',
      {'queue_status': 'synced', 'remote_id': remoteId, 'status': 'posted'},
      where: 'local_id = ?',
      whereArgs: [localId],
    );

    await db.update(
      'sync_queue',
      {'status': 'completed'},
      where: 'complaint_local_id = ? AND status = ?',
      whereArgs: [localId, 'pending'],
    );
  }

  Future<List<Complaint>> getPendingComplaints() async {
    final complaints = await getComplaints();
    return complaints.where((item) => item.queueStatus == 'pending').toList();
  }

  Future<List<Complaint>> fetchRemoteComplaints() async {
    try {
      final remoteData = await _apiClient.fetchComplaints();
      return remoteData.map((json) {
        final data = json as Map<String, dynamic>;
        return Complaint(
          id: data['id'] as int,
          localId: 'remote-${data['id']}',
          citizenName: data['citizen_name'] as String,
          citizenContact: data['citizen_contact'] as String,
          subject: data['subject'] as String,
          description: data['description'] as String,
          queueStatus: 'synced',
          createdAt: data['created_at'] as String,
          remoteId: data['id'] as int,
          latitude: data['latitude'] as double?,
          longitude: data['longitude'] as double?,
          status: data['status'] as String,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
