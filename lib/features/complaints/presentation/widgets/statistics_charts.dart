import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/complaint.dart';

class StatisticsCharts extends StatelessWidget {
  final List<Complaint> complaints;

  const StatisticsCharts({super.key, required this.complaints});

  @override
  Widget build(BuildContext context) {
    final registered = complaints.where((c) => c.status == 'registered').length;
    final posted = complaints.where((c) => c.status == 'posted').length;
    final completed = complaints.where((c) => c.status == 'completed').length;
    final total = complaints.length;

    if (total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data available')),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 60,
              sections: [
                PieChartSectionData(
                  color: const Color(0xFF6366F1),
                  value: registered.toDouble(),
                  title: registered > 0 ? '$registered' : '',
                  radius: 20,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  color: const Color(0xFF10B981),
                  value: posted.toDouble(),
                  title: posted > 0 ? '$posted' : '',
                  radius: 20,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  color: const Color(0xFFF59E0B),
                  value: completed.toDouble(),
                  title: completed > 0 ? '$completed' : '',
                  radius: 20,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$total',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
