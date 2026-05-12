import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../assistant/presentation/assistant_page.dart';
import '../../sync/sync_manager.dart';
import '../data/complaint_repository.dart';
import '../domain/complaint.dart';
import 'file_complaint_page.dart';
import 'complaint_map_page.dart';
import 'widgets/summary_card.dart';
import 'widgets/statistics_charts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    ComplaintRepository? repository,
    SyncManager? syncManager,
  })  : _repository = repository,
        _syncManager = syncManager;

  final ComplaintRepository? _repository;
  final SyncManager? _syncManager;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final ComplaintRepository _repository;
  late final SyncManager _syncManager;
  List<Complaint> _complaints = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? ComplaintRepository();
    _syncManager = widget._syncManager ?? SyncManager(repository: _repository);
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final complaints = await _repository.getComplaints();
    if (!mounted) return;

    setState(() {
      _complaints = complaints;
      _loading = false;
    });
  }

  Future<void> _openComplaintForm() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FileComplaintPage(repository: _repository),
      ),
    );

    if (created == true) {
      await _loadComplaints();
    }
  }

  Future<void> _openMap() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComplaintMapPage(complaints: _complaints),
      ),
    );
  }

  Future<void> _syncNow() async {
    setState(() {
      _loading = true;
    });

    try {
      await _syncManager.syncPendingComplaints();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $error')),
      );
    }
    await _loadComplaints();
  }

  @override
  Widget build(BuildContext context) {
    final registered = _complaints.where((item) => item.status == 'registered').length;
    final posted = _complaints.where((item) => item.status == 'posted').length;
    final completed = _complaints.where((item) => item.status == 'completed').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Text(
                          'Citizen User',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: _syncNow,
                      icon: const Icon(Icons.sync_rounded, color: Colors.indigo),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=samadhan'),
                      ),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Statistics Card (Image 1 inspired)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Analytics',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            StatisticsCharts(complaints: _complaints),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bento Grid (Image 2 inspired)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          SummaryCard(
                            title: 'Registered',
                            count: registered,
                            color: const Color(0xFF6366F1),
                            icon: Icons.app_registration_rounded,
                          ),
                          SummaryCard(
                            title: 'Posted',
                            count: posted,
                            color: const Color(0xFF10B981),
                            icon: Icons.send_rounded,
                          ),
                          SummaryCard(
                            title: 'Completed',
                            count: completed,
                            color: const Color(0xFFF59E0B),
                            icon: Icons.check_circle_rounded,
                          ),
                          // Map View Shortcut (Image 3 inspired)
                          GestureDetector(
                            onTap: _openMap,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.map_rounded, color: Colors.white, size: 32),
                                  Text(
                                    'Nearby\nMap',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Complaints',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'View all',
                            style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_complaints.isEmpty)
                        const Center(child: Text('No complaints filed yet.'))
                      else
                        ..._complaints.take(5).map((complaint) => _buildComplaintTile(complaint)),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openComplaintForm,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text('File Complaint'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildComplaintTile(Complaint complaint) {
    Color statusColor;
    switch (complaint.status) {
      case 'posted':
        statusColor = const Color(0xFF10B981);
      case 'completed':
        statusColor = const Color(0xFFF59E0B);
      default:
        statusColor = const Color(0xFF6366F1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.gavel_rounded, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint.subject,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat.yMMMd().format(DateTime.parse(complaint.createdAt)),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              complaint.status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
