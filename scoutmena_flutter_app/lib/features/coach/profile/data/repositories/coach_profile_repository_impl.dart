import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/network/api_client.dart';
import '../../domain/entities/coach_profile_entity.dart';
import '../../domain/repositories/coach_profile_repository.dart';
import '../models/coach_profile_model.dart';

/// Implementation of CoachProfileRepository
/// Handles API communication for coach profile operations
@LazySingleton(as: CoachProfileRepository)
class CoachProfileRepositoryImpl implements CoachProfileRepository {
  final ApiClient apiClient;

  CoachProfileRepositoryImpl(this.apiClient);

  @override
  Future<CoachProfileEntity?> getProfile() async {
    try {
      final response = await apiClient.get('/coach/profile');
      
      if (response.data['success'] == true) {
        final profileData = response.data['data'];
        return _mapToEntity(profileData);
      }
      return null;
    } on NotFoundException {
      return null;
    } catch (e) {
      throw Exception('Failed to get coach profile: $e');
    }
  }

  @override
  Future<CoachProfileEntity> createProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await apiClient.post('/coach/profile', data: profileData);
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return _mapToEntity(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create profile');
      }
    } catch (e) {
      throw Exception('Failed to create coach profile: $e');
    }
  }

  @override
  Future<CoachProfileEntity> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await apiClient.put('/coach/profile', data: profileData);
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return _mapToEntity(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update coach profile: $e');
    }
  }

  @override
  Future<CoachProfileEntity> uploadProfilePhoto(File photo) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split('/').last,
        ),
      });

      final response = await apiClient.upload('/coach/profile/photo', formData);
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return _mapToEntity(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload photo');
      }
    } catch (e) {
      throw Exception('Failed to upload coach profile photo: $e');
    }
  }

  @override
  Future<CoachProfileEntity> deleteProfilePhoto() async {
    try {
      final response = await apiClient.delete('/coach/profile/photo');
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return _mapToEntity(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete photo');
      }
    } catch (e) {
      throw Exception('Failed to delete coach profile photo: $e');
    }
  }

  @override
  Future<CoachProfileEntity> refreshProfile() async {
    try {
      final response = await apiClient.get('/coach/profile');
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return _mapToEntity(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to refresh profile');
      }
    } catch (e) {
      throw Exception('Failed to refresh coach profile: $e');
    }
  }

  @override
  Future<List<String>> uploadVerificationDocuments(List<File> documents) async {
    try {
      final formData = FormData();
      
      for (var i = 0; i < documents.length; i++) {
        formData.files.add(MapEntry(
          'verification_documents[$i]',
          await MultipartFile.fromFile(
            documents[i].path,
            filename: documents[i].path.split('/').last,
          ),
        ));
      }

      final response = await apiClient.upload(
        '/coach/profile/verification-documents',
        formData,
      );
      
      if (response.data['success'] == true) {
        final urls = (response.data['data']['document_urls'] as List<dynamic>)
            .map((e) => e as String)
            .toList();
        return urls;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload documents');
      }
    } catch (e) {
      throw Exception('Failed to upload verification documents: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getVerificationStatus() async {
    try {
      final response = await apiClient.get('/coach/profile/verification-status');
      
      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get verification status');
      }
    } catch (e) {
      throw Exception('Failed to get verification status: $e');
    }
  }

  /// Map JSON data to entity
  CoachProfileEntity _mapToEntity(Map<String, dynamic> json) {
    return CoachProfileModel.fromJson(json).toEntity();
  }
}
