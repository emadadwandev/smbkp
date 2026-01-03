import 'package:injectable/injectable.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

@lazySingleton
class PlayerService {
  final ApiClient _apiClient;

  PlayerService(this._apiClient);

  /// Get contact requests for the current user
  /// Backend endpoint: GET /api/v1/contact-requests/for-me
  Future<List<ContactRequest>> getContactRequests() async {
    try {
      final response = await _apiClient.get('/contact-requests/for-me');
      final data = response.data['data'] as List;
      return data.map((item) => ContactRequest.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get contact requests: $e');
    }
  }

  /// Respond to a contact request
  /// Backend endpoint: POST /api/v1/contact-requests/{id}/respond
  Future<void> respondToContactRequest(String requestId, String status) async {
    try {
      await _apiClient.post(
        '/contact-requests/$requestId/respond',
        data: {'status': status},
      );
    } catch (e) {
      throw Exception('Failed to respond to contact request: $e');
    }
  }
}

class ContactRequest {
  final String id;
  final String senderName;
  final String senderEmail;
  final String? senderRole;
  final String status;
  final String? message;
  final DateTime createdAt;

  ContactRequest({
    required this.id,
    required this.senderName,
    required this.senderEmail,
    this.senderRole,
    required this.status,
    this.message,
    required this.createdAt,
  });

  factory ContactRequest.fromJson(Map<String, dynamic> json) {
    return ContactRequest(
      id: json['id'].toString(),
      senderName: json['sender_name'] as String? ?? 'Unknown',
      senderEmail: json['sender_email'] as String? ?? '',
      senderRole: json['sender_role'] as String?,
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
