import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../bloc/scout_profile_bloc.dart';
import '../bloc/scout_profile_event.dart';
import '../bloc/scout_profile_state.dart';
import '../../../../../core/themes/app_colors.dart';

/// Scout document upload screen
/// Second step in scout registration: Upload verification documents
class ScoutDocumentUploadScreen extends StatefulWidget {
  const ScoutDocumentUploadScreen({Key? key}) : super(key: key);

  @override
  State<ScoutDocumentUploadScreen> createState() =>
      _ScoutDocumentUploadScreenState();
}

class _ScoutDocumentUploadScreenState
    extends State<ScoutDocumentUploadScreen> {
  final List<File> _selectedDocuments = [];
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('scout.verification_documents'.tr()),
        elevation: 0,
      ),
      body: BlocConsumer<ScoutProfileBloc, ScoutProfileState>(
        listener: (context, state) {
          if (state is VerificationDocumentsUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('scout.documents_uploaded_success'.tr()),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            // Navigate to verification pending screen
            Navigator.pushReplacementNamed(
              context,
              '/scout/verification-pending',
            );
          } else if (state is ScoutProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UploadingVerificationDocuments) {
            return _buildUploadingState(state.progress);
          }

          return _buildUploadForm();
        },
      ),
    );
  }

  Widget _buildUploadForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'scout.upload_credentials'.tr(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'scout.upload_credentials_desc'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Info card
          _buildInfoCard(),
          const SizedBox(height: 24),

          // Upload button
          _buildUploadButton(),
          const SizedBox(height: 24),

          // Selected documents list
          if (_selectedDocuments.isNotEmpty) ...[
            Text(
              'scout.selected_documents'.tr() +
                  ' (${_selectedDocuments.length}/5)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDocumentsList(),
            const SizedBox(height: 24),
          ],

          // Submit button
          if (_selectedDocuments.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitDocuments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'scout.submit_for_verification'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'scout.accepted_documents'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('• ' + 'scout.professional_id'.tr()),
          _buildInfoItem('• ' + 'scout.scout_license'.tr()),
          _buildInfoItem('• ' + 'scout.club_affiliation_letter'.tr()),
          _buildInfoItem('• ' + 'scout.business_card'.tr()),
          const SizedBox(height: 12),
          Text(
            'scout.accepted_formats'.tr() + ': PDF, JPG, PNG',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            'scout.max_file_size'.tr() + ': 10MB',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildUploadButton() {
    return OutlinedButton.icon(
      onPressed: _selectedDocuments.length >= 5 ? null : _pickDocuments,
      icon: const Icon(Icons.upload_file),
      label: Text('scout.select_documents'.tr()),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        side: BorderSide(color: AppColors.primaryBlue),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedDocuments.length,
      itemBuilder: (context, index) {
        final file = _selectedDocuments[index];
        final fileName = file.path.split('/').last;
        final fileSize = _formatFileSize(file.lengthSync());

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              _getFileIcon(fileName),
              color: AppColors.primaryBlue,
              size: 32,
            ),
            title: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              fileSize,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _removeDocument(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadingState(double progress) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 24),
          Text(
            'scout.uploading_documents'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        final files = result.files.map((f) => File(f.path!)).toList();

        // Check total count
        if (_selectedDocuments.length + files.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('scout.max_5_documents'.tr()),
              backgroundColor: AppColors.warning,
            ),
          );
          return;
        }

        // Check file sizes
        for (final file in files) {
          final sizeInMB = file.lengthSync() / (1024 * 1024);
          if (sizeInMB > 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('scout.file_too_large'.tr()),
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
          content: Text('scout.error_picking_files'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _selectedDocuments.removeAt(index);
    });
  }

  void _submitDocuments() {
    if (_selectedDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('scout.select_at_least_one'.tr()),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    context
        .read<ScoutProfileBloc>()
        .add(UploadVerificationDocuments(_selectedDocuments));
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    }
    return Icons.image;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
