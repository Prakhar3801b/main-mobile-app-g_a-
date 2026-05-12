import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samadhan/features/assistant/data/samadhan_assistant_service.dart';
import 'package:samadhan/features/complaints/data/complaint_repository.dart';
import 'package:samadhan/features/complaints/domain/complaint.dart';
import 'package:samadhan/features/complaints/presentation/dashboard_page.dart';
import 'package:samadhan/features/complaints/presentation/file_complaint_page.dart';
import 'package:samadhan/features/sync/sync_manager.dart';

class FakeComplaintRepository extends ComplaintRepository {
  FakeComplaintRepository({List<Complaint>? seedComplaints})
      : _complaints = seedComplaints ?? [];

  final List<Complaint> _complaints;
  bool addCalled = false;

  @override
  Future<void> addComplaint({
    required String citizenName,
    required String citizenContact,
    required String subject,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    addCalled = true;
    _complaints.insert(
      0,
      Complaint(
        localId: 'local-test-id',
        citizenName: citizenName,
        citizenContact: citizenContact,
        subject: subject,
        description: description,
        queueStatus: 'pending',
        createdAt: DateTime.now().toIso8601String(),
        latitude: latitude,
        longitude: longitude,
        status: 'registered',
      ),
    );
  }

  @override
  Future<List<Complaint>> getComplaints() async => _complaints;

  @override
  Future<void> markSynced(String localId, int remoteId) async {}
}

class FakeSyncManager extends SyncManager {
  FakeSyncManager() : super();

  bool syncCalled = false;

  @override
  Future<void> syncPendingComplaints() async {
    syncCalled = true;
  }
}

void main() {
  testWidgets('dashboard renders Samadhan summary and AI assistant entry', (tester) async {
    final repository = FakeComplaintRepository(
      seedComplaints: [
        Complaint(
          localId: '1',
          citizenName: 'Asha',
          citizenContact: '9999999999',
          subject: 'Broken road',
          description: 'Large pothole near bus stop for three days.',
          queueStatus: 'pending',
          createdAt: DateTime.parse('2026-05-06T09:00:00').toIso8601String(),
          status: 'registered',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardPage(
          repository: repository,
          syncManager: FakeSyncManager(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Citizen User'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Broken road'), findsOneWidget);
    expect(find.text('REGISTERED'), findsOneWidget);
  });

  testWidgets('complaint form saves complaint and shows AI tip action', (tester) async {
    final repository = FakeComplaintRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: FileComplaintPage(
          repository: repository,
          assistantService: SamadhanAssistantService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('File Complaint in Samadhan'), findsOneWidget);
    expect(find.text('Get AI drafting tip'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Ravi');
    await tester.enterText(find.byType(TextFormField).at(1), '9876543210');
    await tester.enterText(find.byType(TextFormField).at(2), 'Water leakage');
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'There is a major water leakage near the school entrance.',
    );

    await tester.tap(find.text('Save Offline'));
    await tester.pumpAndSettle();

    expect(repository.addCalled, isTrue);
  });
}
