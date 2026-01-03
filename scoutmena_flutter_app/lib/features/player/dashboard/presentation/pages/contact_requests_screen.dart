import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/services/player_service.dart';
import '../../../../../injection.dart';

class ContactRequestsScreen extends StatefulWidget {
  const ContactRequestsScreen({super.key});

  @override
  State<ContactRequestsScreen> createState() => _ContactRequestsScreenState();
}

class _ContactRequestsScreenState extends State<ContactRequestsScreen> {
  final _playerService = getIt<PlayerService>();
  List<ContactRequest> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final requests = await _playerService.getContactRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _respond(String id, String status) async {
    try {
      await _playerService.respondToContactRequest(id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request $status successfully')),
        );
        _loadRequests(); // Reload list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Contact Requests'),
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _requests.isEmpty
                  ? const Center(child: Text('No contact requests yet', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final request = _requests[index];
                        return _buildRequestCard(request);
                      },
                    ),
    );
  }

  Widget _buildRequestCard(ContactRequest request) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.senderName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              request.senderRole ?? 'Scout',
              style: const TextStyle(color: AppColors.primaryBlue, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (request.message != null) ...[
              Text(
                request.message!,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
            ],
            if (request.status == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _respond(request.id, 'declined'),
                    child: const Text('Decline', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _respond(request.id, 'approved'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                    child: const Text('Approve', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.primaryGreen;
      case 'declined':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
