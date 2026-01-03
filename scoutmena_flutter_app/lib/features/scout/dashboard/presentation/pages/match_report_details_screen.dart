import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/services/scout_service.dart';

class MatchReportDetailsScreen extends StatelessWidget {
  final MatchReport report;

  const MatchReportDetailsScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        title: const Text(
          'Match Report Details',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Match Details'),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.emoji_events_outlined, 'Tournament', report.tournamentName),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.location_on_outlined, 'Location', report.location),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.calendar_today, 'Date', DateFormat('MMM dd, yyyy').format(report.matchDate)),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Teams & Result'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDetailRow(Icons.shield_outlined, 'Team A', report.teamA)),
                const SizedBox(width: 16),
                Expanded(child: _buildDetailRow(Icons.shield_outlined, 'Team B', report.teamB)),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.scoreboard_outlined, 'Result', report.result),
            if (report.mvp != null && report.mvp!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.star_outline, 'MVP', report.mvp!),
            ],

            if (report.playersToWatch != null && report.playersToWatch!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Players to Watch'),
              const SizedBox(height: 16),
              ...report.playersToWatch!.map((player) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player['name'] ?? 'Unknown',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (player['jersey'] != null && player['jersey'].isNotEmpty)
                              Text(
                                'Jersey #${player['jersey']}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
            
            if (report.notes != null && report.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Notes'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Text(
                  report.notes!,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
