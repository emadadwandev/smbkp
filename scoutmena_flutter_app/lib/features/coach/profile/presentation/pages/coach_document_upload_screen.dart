import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/themes/app_colors.dart';
import '../bloc/coach_profile_bloc.dart';
import '../bloc/coach_profile_event.dart';
import '../bloc/coach_profile_state.dart';

/// Screen: Coach document upload
/// Allows coaches to upload verification documents (license, certificates, ID, etc.)
class CoachDocumentUploadScreen extends StatefulWidget {
  const CoachDocumentUploadScreen({super.key});

  @override
  State<CoachDocumentUploadScreen> createState() =>
      _CoachDocumentUploadScreenState();
}

class _CoachDocumentUploadScreenState
    extends State<CoachDocumentUploadScreen> {
  final List<File> _selectedDocuments = [];
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('coach.verification_documents'.tr()),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: BlocConsumer<CoachProfileBloc, CoachProfileState>(
        listener: (context, state) {
          if (state is CoachVerificationDocumentsUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('coach.documents_uploaded_success'.tr()),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            Navigator.pushReplacementNamed(context, '/coach/verification-pending');
          } else if (state is CoachProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UploadingCoachVerificationDocuments) {
            _isUploading = true;
          } else {
            _isUploading = false;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'coach.upload_credentials'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'coach.upload_credentials_desc'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),

                // Accepted Documents Info Card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: AppColors.primaryBlue),
                            const SizedBox(width: 8),
                            Text(
                              'coach.accepted_documents'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDocumentType('coach.coaching_license'.tr()),
                        _buildDocumentType('coach.professional_id'.tr()),
                        _buildDocumentType('coach.club_affiliation_letter'.tr()),
                        _buildDocumentType('coach.certificates'.tr()),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 16, color: AppColors.primaryGreen),
                            const SizedBox(width: 8),
                            Text(
                              '${'coach.accepted_formats'.tr()}: PDF, JPG, PNG',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.storage,
                                size: 16, color: AppColors.primaryGreen),
                            const SizedBox(width: 8),
                            Text(
                              '${'coach.max_file_size'.tr()}: 10MB',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Document Picker Button
                OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickDocuments,
                  icon: const Icon(Icons.attach_file),
                  label: Text('coach.select_documents'.tr()),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primaryBlue),
                    foregroundColor: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 24),

                // Selected Documents List
                if (_selectedDocuments.isNotEmpty) ...[
                  Text(
                    'coach.selected_documents'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._selectedDocuments.map((file) => _buildDocumentCard(file)),
                  const SizedBox(height: 24),
                ],

                // Upload Progress
                if (state is UploadingCoachVerificationDocuments) ...[
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: state.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${'coach.uploading_documents'.tr()} ${(state.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Submit Button
                ElevatedButton(
                  onPressed: _selectedDocuments.isEmpty || _isUploading
                      ? null
                      : _submitDocuments,
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'coach.submit_for_verification'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentType(String type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Text(
            type,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(File file) {
    final fileName = file.path.split('/').last;
    final fileSize = _formatFileSize(file.lengthSync());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _getFileIcon(fileName),
              size: 32,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileSize,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _removeDocument(file),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    }
    return Icons.image;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        final files = result.files.map((file) => File(file.path!)).toList();

        // Validate number of files
        if (_selectedDocuments.length + files.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('coach.max_5_documents'.tr()),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        // Validate file sizes
        for (final file in files) {
          final fileSizeInMB = file.lengthSync() / (1024 * 1024);
          if (fileSizeInMB > 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('coach.file_too_large'.tr()),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
        }

        setState(() {
          _selectedDocuments.addAll(files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('coach.error_picking_files'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeDocument(File file) {
    setState(() {
      _selectedDocuments.remove(file);
    });
  }

  void _submitDocuments() {
    if (_selectedDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('coach.select_at_least_one'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<CoachProfileBloc>().add(
          UploadCoachVerificationDocuments(_selectedDocuments),
        );
  }
}
