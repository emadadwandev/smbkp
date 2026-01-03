import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/career_entry.dart';

class CareerTimelineWidget extends StatelessWidget {
  final List<CareerEntry> careerHistory;

  const CareerTimelineWidget({
    Key? key,
    required this.careerHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (careerHistory.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No career history added yet.'),
        ),
      );
    }

    // Sort by start date descending (newest first)
    final sortedHistory = List<CareerEntry>.from(careerHistory)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedHistory.length,
      itemBuilder: (context, index) {
        final entry = sortedHistory[index];
        return _buildTimelineItem(context, entry, index == sortedHistory.length - 1);
      },
    );
  }

  Widget _buildTimelineItem(BuildContext context, CareerEntry entry, bool isLast) {
    final dateFormat = DateFormat('MMM yyyy');
    final startDateStr = dateFormat.format(entry.startDate);
    final endDateStr = entry.isCurrent
        ? 'Present'
        : (entry.endDate != null ? dateFormat.format(entry.endDate!) : 'Unknown');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.clubName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$startDateStr - $endDateStr',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
