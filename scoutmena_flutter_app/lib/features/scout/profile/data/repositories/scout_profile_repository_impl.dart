import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/network/api_client.dart';
import '../../domain/entities/scout_profile_entity.dart';
import '../../domain/repositories/scout_profile_repository.dart';

/// Implementation of ScoutProfileRepository
/// Handles API communication for scout profile operations
@LazySingleton(as: ScoutProfileRepository)
class ScoutProfileRepositoryImpl implements ScoutProfileRepository {
  final ApiClient apiClient;

  ScoutProfileRepositoryImpl(this.apiClient);

  @override
  Future<ScoutProfileEntity?> getProfile() async {
    try {
      final response = await apiClient.get('/scout/profile');
      
      if (response.data['success'] == true) {
        final profileData = response.data['data'];
        return _mapToEntity(profileData);
      }
      return null;
    } on NotFoundException {
      return null;
    } catch (e) {
      throw Exception('Failed to get scout profile: $e');
    }
  }

  @override
  Future<ScoutProfileEntity> createProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await apiClient.post('/scout/profile', data: profileData);
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return _mapToEntity(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create profile');
      }
    } catch (e) {
      throw Exception('Failed to create scout profile: $e');
    }
  }

  @override
  Future<ScoutProfileEntity> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await apiClient.put('/scout/profile', data: profileData);
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return _mapToEntity(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update scout profile: $e');
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
        '/scout/profile/verification-documents',
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
  Future<ScoutProfileEntity> uploadProfilePhoto(File photo) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split('/').last,
        ),
      });

      final response = await apiClient.upload('/scout/profile/photo', formData);
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return _mapToEntity(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload photo');
      }
    } catch (e) {
      throw Exception('Failed to upload scout profile photo: $e');
    }
  }

  @override
  Future<ScoutProfileEntity> deleteProfilePhoto() async {
    try {
      final response = await apiClient.delete('/scout/profile/photo');
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return _mapToEntity(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete photo');
      }
    } catch (e) {
      throw Exception('Failed to delete scout profile photo: $e');
    }
  }

  @override
  Future<ScoutProfileEntity> refreshProfile() async {
    try {
      final response = await apiClient.get('/scout/profile');
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return _mapToEntity(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to refresh profile');
      }
    } catch (e) {
      throw Exception('Failed to refresh scout profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getVerificationStatus() async {
    try {
      final response = await apiClient.get('/scout/profile/verification-status');
      
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
  ScoutProfileEntity _mapToEntity(Map<String, dynamic> json) {
    return ScoutProfileEntity(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      clubName: json['club_name']?.toString(),
      jobTitle: json['job_title']?.toString(),
      specializations: (json['specializations'] as List<dynamic>?)
          ?.map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(),
      country: json['country']?.toString() ?? '',
      leaguesOfInterest: (json['leagues_of_interest'] as List<dynamic>?)
          ?.map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(),
      certificates: (json['certificates'] as List<dynamic>?)
          ?.map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(),
      bio: json['bio']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      socialLinks: json['social_links'] != null && json['social_links'] is Map
          ? (json['social_links'] as Map).map((key, value) => 
              MapEntry(key.toString(), value?.toString() ?? ''))
          : null,
      profilePhotoUrl: json['profile_photo_url']?.toString(),
      isVerified: json['is_verified'] == true,
      isActive: json['is_active'] == true,
      verificationStatus: json['verification_status']?.toString(),
      verificationDocumentUrls: (json['verification_document_urls'] as List<dynamic>?)
          ?.map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList() ??
          (json['verification_documents'] as List<dynamic>?)
          ?.map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(),
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
