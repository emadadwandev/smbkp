import 'package:injectable/injectable.dart';
import '../network/api_client.dart';

@lazySingleton
class SupportService {
  final ApiClient _apiClient;

  SupportService(this._apiClient);

  /// Submit contact/feedback form
  /// Backend endpoint: POST /api/v1/support/contact
  Future<ContactResponse> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String category,
    required String message,
    required String type, // 'support' or 'feedback'
  }) async {
    try {
      final response = await _apiClient.post(
        '/support/contact',
        data: {
          'name': name,
          'email': email,
          'subject': subject,
          'category': category,
          'message': message,
          'type': type,
        },
      );

      return ContactResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to submit contact form: $e');
    }
  }

  /// Request user data export (GDPR compliance)
  /// Backend endpoint: POST /api/v1/user/data-request
  Future<DataRequestResponse> requestUserData() async {
    try {
      final response = await _apiClient.post('/user/data-request');
      return DataRequestResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to request user data: $e');
    }
  }

  /// Request account deletion (GDPR compliance)
  /// Backend endpoint: POST /api/v1/user/delete-request
  Future<DeleteAccountResponse> requestAccountDeletion({String? reason}) async {
    try {
      final response = await _apiClient.post(
        '/user/delete-request',
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );

      return DeleteAccountResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to request account deletion: $e');
    }
  }
}

/// Response models
class ContactResponse {
  final bool success;
  final String message;
  final int? ticketId;
  final String? ticketNumber;

  ContactResponse({
    required this.success,
    required this.message,
    this.ticketId,
    this.ticketNumber,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Message sent successfully',
      ticketId: json['data']?['ticket_id'] as int?,
      ticketNumber: json['data']?['ticket_number'] as String?,
    );
  }
}

class DataRequestResponse {
  final bool success;
  final String message;
  final int? requestId;
  final String? requestNumber;
  final String? estimatedCompletion;

  DataRequestResponse({
    required this.success,
    required this.message,
    this.requestId,
    this.requestNumber,
    this.estimatedCompletion,
  });

  factory DataRequestResponse.fromJson(Map<String, dynamic> json) {
    return DataRequestResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Data request submitted successfully',
      requestId: json['data']?['request_id'] as int?,
      requestNumber: json['data']?['request_number'] as String?,
      estimatedCompletion: json['data']?['estimated_completion'] as String?,
    );
  }
}

class DeleteAccountResponse {
  final bool success;
  final String message;
  final int? requestId;
  final String? requestNumber;
  final String? scheduledDeletionDate;

  DeleteAccountResponse({
    required this.success,
    required this.message,
    this.requestId,
    this.requestNumber,
    this.scheduledDeletionDate,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAccountResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Account deletion request submitted',
      requestId: json['data']?['request_id'] as int?,
      requestNumber: json['data']?['request_number'] as String?,
      scheduledDeletionDate: json['data']?['scheduled_deletion_date'] as String?,
    );
  }
}
