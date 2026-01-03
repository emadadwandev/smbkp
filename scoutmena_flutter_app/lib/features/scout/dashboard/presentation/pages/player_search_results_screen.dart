import 'package:flutter/material.dart';
import '../../../../../core/services/scout_service.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../injection.dart';
import '../widgets/player_list_card.dart';

class PlayerSearchResultsScreen extends StatefulWidget {
  final Map<String, dynamic> filters;

  const PlayerSearchResultsScreen({super.key, required this.filters});

  @override
  State<PlayerSearchResultsScreen> createState() => _PlayerSearchResultsScreenState();
}

class _PlayerSearchResultsScreenState extends State<PlayerSearchResultsScreen> {
  final ScoutService _scoutService = getIt<ScoutService>();
  bool _isLoading = true;
  List<PlayerSearchResult> _results = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _scoutService.searchPlayers(
        query: widget.filters['query'],
        position: widget.filters['position'],
        ageMin: widget.filters['ageMin'],
        ageMax: widget.filters['ageMax'],
        country: widget.filters['country'],
        gender: widget.filters['gender'],
        preferredFoot: widget.filters['foot'],
      );
      setState(() {
        _results = response.players;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search Results',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          const Text(
                            'No players found matching your criteria',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Adjust Filters', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final player = _results[index];
                        return PlayerListCard(
                          id: player.id,
                          name: player.name,
                          primaryPosition: player.primaryPosition,
                          currentClub: player.currentClub,
                          profilePhotoUrl: player.profilePhotoUrl,
                          nationality: player.nationality,
                          city: player.city,
                          country: player.country,
                        );
                      },
                    ),
    );
  }
}
