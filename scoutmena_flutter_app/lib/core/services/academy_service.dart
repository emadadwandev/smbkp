import 'package:injectable/injectable.dart';
import '../network/api_client.dart';

@lazySingleton
class AcademyService {
  final ApiClient _apiClient;

  AcademyService(this._apiClient);

  /// Get list of academies
  /// Backend endpoint: GET /api/v1/academies
  Future<List<Map<String, dynamic>>> getAcademies() async {
    try {
      final response = await _apiClient.get('/academies');
      final data = response.data['data'] as List;
      return data.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to get academies: $e');
    }
  }
}
