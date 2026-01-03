import 'package:flutter/material.dart';

class RecentActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final bool hasCalendarIcon;

  const RecentActivityItem({
    super.key,
    required this.title,
    required this.time,
    this.hasCalendarIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (hasCalendarIcon)
            Icon(
              Icons.calendar_today_outlined,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
        ],
      ),
    );
  }
}

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          RecentActivityItem(
            title: 'New player profile submitted',
            time: '2h ago',
            hasCalendarIcon: true,
          ),
          RecentActivityItem(
            title: 'Match report available',
            time: 'Yesterday',
          ),
          RecentActivityItem(
            title: 'Profile verification completed',
            time: '2d ago',
            hasCalendarIcon: true,
          ),
        ],
      ),
    );
  }
}
