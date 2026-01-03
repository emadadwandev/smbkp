import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

/// Backend integration helper
/// Test connectivity and API endpoints
class BackendIntegration {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  BackendIntegration(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Test backend connectivity
  /// Returns true if backend is reachable
  Future<bool> testConnection() async {
    try {
      // Try Laravel root - even 404 means server is reachable
      final response = await _dio.get('/');
      return response.statusCode == 200 || response.statusCode == 404;
    } on DioException catch (e) {
      // If we get 404, server is reachable
      if (e.response?.statusCode == 404) return true;
    //  print('Backend connection failed: $e');
      return false;
    } catch (e) {
    //  print('Backend connection failed: $e');
      return false;
    }
  }

  /// Test authentication endpoint
  Future<Map<String, dynamic>> testAuthEndpoint() async {
    try {
      final response = await _dio.post(
        ApiConstants.sendOtp,
        data: {
          'phone': '+201234567890',
          'method': 'sms',
        },
      );
      return {
        'success': true,
        'status_code': response.statusCode,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get backend status
  Future<Map<String, dynamic>> getBackendStatus() async {
    try {
      // Try root endpoint - Laravel APIs often return 404 for root
      final response = await _dio.get('/');
      return {
        'reachable': true,
        'status_code': response.statusCode,
        'base_url': ApiConstants.baseUrl,
        'api_version': ApiConstants.apiVersion,
        'full_url': ApiConstants.apiBaseUrl,
        'message': 'Backend accessible',
      };
    } on DioException catch (e) {
      // 404 means server is reachable but no root route (expected for Laravel API)
      if (e.response?.statusCode == 404) {
        return {
          'reachable': true,
          'status_code': 404,
          'base_url': ApiConstants.baseUrl,
          'api_version': ApiConstants.apiVersion,
          'full_url': ApiConstants.apiBaseUrl,
          'message': 'Backend reachable (Laravel API - no root endpoint)',
        };
      }
      return {
        'reachable': false,
        'base_url': ApiConstants.baseUrl,
        'api_version': ApiConstants.apiVersion,
        'full_url': ApiConstants.apiBaseUrl,
        'error': e.message ?? 'Connection failed',
      };
    } catch (e) {
      return {
        'reachable': false,
        'base_url': ApiConstants.baseUrl,
        'api_version': ApiConstants.apiVersion,
        'full_url': ApiConstants.apiBaseUrl,
        'error': e.toString(),
      };
    }
  }

  /// Test all critical endpoints
  Future<Map<String, dynamic>> testCriticalEndpoints() async {
    final results = <String, dynamic>{};

    // Test authentication endpoints
    results['auth'] = await _testEndpoint('POST', ApiConstants.sendOtp);
    
    // Test player endpoints
    results['player_profile'] = await _testEndpoint('GET', ApiConstants.playerProfile);
    
    // Test scout endpoints
    results['scout_profile'] = await _testEndpoint('GET', ApiConstants.scoutProfile);
    
    // Test coach endpoints
    results['coach_profile'] = await _testEndpoint('GET', ApiConstants.coachProfile);

    return results;
  }

  Future<Map<String, dynamic>> _testEndpoint(String method, String path) async {
    try {
      Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(path);
          break;
        case 'POST':
          response = await _dio.post(path);
          break;
        default:
          return {'error': 'Unsupported method'};
      }
      
      return {
        'available': true,
        'status_code': response.statusCode,
        'method': method,
        'path': path,
        'message': 'OK',
      };
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        
        // Endpoint exists but requires authentication or valid data
        final isAvailable = statusCode == 401 || // Unauthorized (needs auth)
                           statusCode == 400 || // Bad Request (needs valid data)
                           statusCode == 422;   // Unprocessable Entity (validation error)
        
        return {
          'available': isAvailable,
          'status_code': statusCode,
          'method': method,
          'path': path,
          'message': _getStatusMessage(statusCode),
          'error': isAvailable ? null : e.message,
        };
      }
      return {
        'available': false,
        'method': method,
        'path': path,
        'error': e.toString(),
      };
    }
  }
  
  String _getStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 200: return 'OK';
      case 201: return 'Created';
      case 400: return 'Endpoint exists (needs valid data)';
      case 401: return 'Endpoint exists (needs authentication)';
      case 404: return 'Endpoint not found';
      case 422: return 'Endpoint exists (validation error)';
      case 500: return 'Server error';
      default: return 'Status: $statusCode';
    }
  }
}
