import 'package:flutter/material.dart';
import '../pages/player_profile_screen.dart';

class PlayerListCard extends StatelessWidget {
  final String id;
  final String name;
  final String primaryPosition;
  final String? currentClub;
  final String? profilePhotoUrl;
  final String nationality;
  final String? city;
  final String? country;
  final VoidCallback? onReturn;

  const PlayerListCard({
    super.key,
    required this.id,
    required this.name,
    required this.primaryPosition,
    this.currentClub,
    this.profilePhotoUrl,
    required this.nationality,
    this.city,
    this.country,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final locationParts = [city, country].where((e) => e != null && e.isNotEmpty).toList();
    final locationText = locationParts.isNotEmpty ? locationParts.join(', ') : nationality;
    final displayName = name.isNotEmpty ? name : 'Unknown Player';
    final displayPosition = primaryPosition.isNotEmpty ? primaryPosition : 'Position N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerProfileScreen(
                  playerId: id,
                  initialName: displayName,
                  initialPhotoUrl: profilePhotoUrl,
                ),
              ),
            ).then((_) {
              if (onReturn != null) onReturn!();
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 2),
                    image: profilePhotoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(profilePhotoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: profilePhotoUrl == null
                      ? Center(
                          child: Text(
                            displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : '?',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              displayPosition,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (currentClub != null && currentClub!.isNotEmpty)
                            Expanded(
                              child: Text(
                                currentClub!,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            Text(
                              "Free Agent",
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationText.isNotEmpty ? locationText : 'Location Unknown',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
