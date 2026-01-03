import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/themes/app_colors.dart';

/// Step 4 of 4: Media Upload
/// Profile photo, hero image, and gallery photos
class ProfileStepFourScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onComplete;
  final VoidCallback onBack;

  const ProfileStepFourScreen({
    super.key,
    required this.initialData,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<ProfileStepFourScreen> createState() => _ProfileStepFourScreenState();
}

class _ProfileStepFourScreenState extends State<ProfileStepFourScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _profilePhoto;
  File? _heroImage;
  List<File> _galleryPhotos = [];
  
  final int _maxGalleryPhotos = 5;

  @override
  void initState() {
    super.initState();
    // Note: In real implementation, we'd load existing photos from URLs
  }

  Future<void> _pickProfilePhoto() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _profilePhoto = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickHeroImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _heroImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickGalleryPhoto() async {
    if (_galleryPhotos.length >= _maxGalleryPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.max_gallery_photos'.tr(args: [_maxGalleryPhotos.toString()])),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _galleryPhotos.add(File(pickedFile.path));
      });
    }
  }

  void _removeGalleryPhoto(int index) {
    setState(() {
      _galleryPhotos.removeAt(index);
    });
  }

  void _handleComplete() {
    // Validate required photos
    if (_profilePhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.profile_photo_required'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_heroImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.hero_image_required'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final data = {
      ...widget.initialData,
      'profilePhoto': _profilePhoto,
      'heroImage': _heroImage,
      'galleryPhotos': _galleryPhotos,
    };
    
    widget.onComplete(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile.create_profile'.tr()),
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(4),
            const SizedBox(height: 24),
            
            Text(
              'profile.media_upload'.tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'profile.media_upload_subtitle'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            // Profile Photo (Required)
            _buildSectionTitle('profile.profile_photo'.tr(), required: true),
            const SizedBox(height: 8),
            Text(
              'profile.profile_photo_hint'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            _buildProfilePhotoCard(),
            const SizedBox(height: 32),
            
            // Hero Image (Required)
            _buildSectionTitle('profile.hero_image'.tr(), required: true),
            const SizedBox(height: 8),
            Text(
              'profile.hero_image_hint'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            _buildHeroImageCard(),
            const SizedBox(height: 32),
            
            // Gallery Photos (Optional)
            _buildSectionTitle(
              'profile.gallery_photos'.tr(),
              subtitle: '(${'profile.max'.tr()} $_maxGalleryPhotos)',
            ),
            const SizedBox(height: 8),
            Text(
              'profile.gallery_photos_hint'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            _buildGallerySection(),
            const SizedBox(height: 32),
            
            // Info Card
            _buildInfoCard(),
            const SizedBox(height: 32),
            
            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'common.previous'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'common.complete'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      children: List.generate(
        4,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: index < currentStep
                  ? AppColors.primaryBlue
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle, bool required = false}) {
    return Row(
      children: [
        Text(
          required ? '$title *' : title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfilePhotoCard() {
    return GestureDetector(
      onTap: _pickProfilePhoto,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: _profilePhoto != null ? AppColors.primaryBlue : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: _profilePhoto != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      _profilePhoto!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _pickProfilePhoto,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'profile.upload_profile_photo'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeroImageCard() {
    return GestureDetector(
      onTap: _pickHeroImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: _heroImage != null ? AppColors.primaryBlue : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: _heroImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      _heroImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _pickHeroImage,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.landscape, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'profile.upload_hero_image'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGallerySection() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _galleryPhotos.length + 
              (_galleryPhotos.length < _maxGalleryPhotos ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _galleryPhotos.length) {
              return _buildGalleryPhotoCard(_galleryPhotos[index], index);
            } else {
              return _buildAddPhotoCard();
            }
          },
        ),
        if (_galleryPhotos.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'profile.no_gallery_photos'.tr(),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGalleryPhotoCard(File photo, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            photo,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _removeGalleryPhoto(index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: _pickGalleryPhoto,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text(
              'common.add'.tr(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'profile.media_tips'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'profile.media_tips_content'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
