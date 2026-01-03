import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../injection.dart';

class UploadPhotosScreen extends StatefulWidget {
  const UploadPhotosScreen({Key? key}) : super(key: key);

  @override
  State<UploadPhotosScreen> createState() => _UploadPhotosScreenState();
}

class _UploadPhotosScreenState extends State<UploadPhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;
  XFile? _profilePhoto;
  XFile? _heroImage;

  Future<void> _pickProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _profilePhoto = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('errors.network_error'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickHeroImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _heroImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('errors.network_error'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickGalleryImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          // Limit to 5 gallery photos
          final remaining = 5 - _selectedImages.length;
          if (remaining > 0) {
            _selectedImages.addAll(images.take(remaining));
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('errors.network_error'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadPhotos() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final apiClient = getIt<ApiClient>();

      // Upload profile photo
      if (_profilePhoto != null) {
        final formData = FormData.fromMap({
          'photo': await MultipartFile.fromFile(
            _profilePhoto!.path,
            filename: 'profile_photo.jpg',
          ),
        });

        await apiClient.upload(
          '/player/profile/photo',
          formData,
        );
      }

      // Upload hero image
      if (_heroImage != null) {
        final formData = FormData.fromMap({
          'photo': await MultipartFile.fromFile(
            _heroImage!.path,
            filename: 'hero_image.jpg',
          ),
          'is_hero': true,
        });

        await apiClient.upload(
          '/player/profile/photos',
          formData,
        );
      }

      // Upload gallery photos
      for (var i = 0; i < _selectedImages.length; i++) {
        final formData = FormData.fromMap({
          'photo': await MultipartFile.fromFile(
            _selectedImages[i].path,
            filename: 'gallery_${i + 1}.jpg',
          ),
          'is_hero': false,
        });

        await apiClient.upload(
          '/player/profile/photos',
          formData,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('success.photo_uploaded'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errors.server_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard.upload_photos'.tr()),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Photo Section
          Text(
            'profile.profile_photo'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'profile.profile_photo_hint'.tr(),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          _buildPhotoPickerCard(
            label: 'profile.upload_profile_photo'.tr(),
            image: _profilePhoto,
            onPick: _pickProfilePhoto,
            onRemove: () => setState(() => _profilePhoto = null),
            aspectRatio: 1.0,
          ),
          const SizedBox(height: 24),

          // Hero Image Section
          Text(
            'profile.hero_image'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'profile.hero_image_hint'.tr(),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          _buildPhotoPickerCard(
            label: 'profile.upload_hero_image'.tr(),
            image: _heroImage,
            onPick: _pickHeroImage,
            onRemove: () => setState(() => _heroImage = null),
            aspectRatio: 16 / 9,
          ),
          const SizedBox(height: 24),

          // Gallery Photos Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'profile.gallery_photos'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_selectedImages.length}/5',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'profile.gallery_photos_hint'.tr(),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          if (_selectedImages.isEmpty)
            ElevatedButton.icon(
              onPressed: _selectedImages.length < 5 ? _pickGalleryImages : null,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text('profile.upload_photo'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _selectedImages.length + (_selectedImages.length < 5 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return InkWell(
                    onTap: _pickGalleryImages,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, color: Colors.grey[400], size: 32),
                    ),
                  );
                }

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                              _selectedImages[index].path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.file(
                              File(_selectedImages[index].path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 24),

          // Media Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'profile.media_tips'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'profile.media_tips_content'.tr(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: (_profilePhoto != null || _heroImage != null || _selectedImages.isNotEmpty) && !_isUploading
                ? _uploadPhotos
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isUploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'common.submit'.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPickerCard({
    required String label,
    required XFile? image,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    required double aspectRatio,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: image == null
            ? InkWell(
                onTap: onPick,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(
                            image.path,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: onPick,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
