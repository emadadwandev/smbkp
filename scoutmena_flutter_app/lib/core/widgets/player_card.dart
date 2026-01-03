import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class ProfessionalPlayerCard extends StatelessWidget {
  final String name;
  final String position;
  final int age;
  final String nationality;
  final String? club;
  final String? photoUrl;
  final int completionScore;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onAddToTeam;

  const ProfessionalPlayerCard({
    super.key,
    required this.name,
    required this.position,
    required this.age,
    required this.nationality,
    this.club,
    this.photoUrl,
    this.completionScore = 0,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmark,
    this.onAddToTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: Row(
            children: [
              // Left Side: Image & Gradient
              SizedBox(
                width: 140,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    photoUrl != null
                        ? Image.network(
                            photoUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.primaryBlue,
                            child: Icon(
                              Icons.person,
                              size: 64,
                              color: AppColors.white,
                            ),
                          ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black,
                          ],
                        ),
                      ),
                    ),
                    // Completion Badge
                    if (completionScore > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getScoreColor(completionScore),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$completionScore%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Right Side: Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    position.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (onBookmark != null)
                            InkWell(
                              onTap: onBookmark,
                              child: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: isBookmarked ? AppColors.primaryBlue : Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      
                      // Stats Row
                      Row(
                        children: [
                          _buildStatItem(context, 'Age', '$age'),
                          _buildDivider(),
                          _buildStatItem(context, 'Nat', nationality),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (club != null)
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.shield_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      club!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (onAddToTeam != null)
                            InkWell(
                              onTap: onAddToTeam,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.add, size: 14, color: AppColors.primaryBlue),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Add to Team',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.primaryGreen;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
