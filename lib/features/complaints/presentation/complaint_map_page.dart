import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../domain/complaint.dart';
import '../data/complaint_repository.dart';

class ComplaintMapPage extends StatefulWidget {
  final List<Complaint> complaints;

  const ComplaintMapPage({super.key, required this.complaints});

  @override
  State<ComplaintMapPage> createState() => _ComplaintMapPageState();
}

class _ComplaintMapPageState extends State<ComplaintMapPage> {
  final MapController _mapController = MapController();
  final ComplaintRepository _repository = ComplaintRepository();
  LatLng _center = const LatLng(20.5937, 78.9629); // Default center (India)
  bool _isLoadingLocation = true;
  List<Complaint> _remoteComplaints = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchCommunityComplaints();
  }

  Future<void> _fetchCommunityComplaints() async {
    final remote = await _repository.fetchRemoteComplaints();
    if (!mounted) return;
    setState(() {
      _remoteComplaints = remote;
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      _isLoadingLocation = false;
    });

    _mapController.move(_center, 13.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Grievances'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 5.0,
        ),
        children: [
          // Premium Dark Matter Tiles from CartoDB (No API key needed for basic usage)
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.samadhan.app',
          ),
          MarkerLayer(
            markers: [
              // User Location Marker
              if (!_isLoadingLocation)
                Marker(
                  point: _center,
                  width: 60,
                  height: 60,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                ),
              // User's Local Complaints (Blue markers)
              ...widget.complaints
                  .where((c) => c.latitude != null && c.longitude != null)
                  .map(
                    (c) => Marker(
                      point: LatLng(c.latitude!, c.longitude!),
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () => _showComplaintSummary(context, c),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF6366F1), // Indigo
                          size: 40,
                        ),
                      ),
                    ),
                  ),
              // Community Complaints (Grey/Orange markers)
              ..._remoteComplaints
                  .where((c) =>
                      c.latitude != null &&
                      c.longitude != null &&
                      !widget.complaints.any((local) => local.remoteId == c.remoteId))
                  .map(
                    (c) => Marker(
                      point: LatLng(c.latitude!, c.longitude!),
                      width: 70,
                      height: 70,
                      child: GestureDetector(
                        onTap: () => _showComplaintSummary(context, c),
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.orangeAccent,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _determinePosition,
        backgroundColor: Colors.white,
        child: const Icon(Icons.gps_fixed, color: Colors.black),
      ),
    );
  }

  void _showComplaintSummary(BuildContext context, Complaint complaint) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              complaint.subject,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              complaint.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Chip(
                  label: Text(complaint.status.toUpperCase()),
                  backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                  labelStyle: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
