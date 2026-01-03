import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/otp_service.dart';
import '../../../../core/themes/app_colors.dart';

/// Document upload screen for scout/coach verification
/// Collects National ID/Passport and professional certificates
class VerificationDocumentsScreen extends StatefulWidget {
  final String userId;
  final String accountType;
  final VoidCallback onComplete;

  const VerificationDocumentsScreen({
    Key? key,
    required this.userId,
    required this.accountType,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<VerificationDocumentsScreen> createState() =>
      _VerificationDocumentsScreenState();
}

class _VerificationDocumentsScreenState
    extends State<VerificationDocumentsScreen> {
  final _otpService = GetIt.instance<OtpService>();

  String _identityDocumentType = 'national_id';
  File? _nationalIdFile;
  File? _passportFile;
  final List<File> _professionalCertificates = [];
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _pickFile(String fileType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          final file = File(result.files.single.path!);
          if (fileType == 'national_id') {
            _nationalIdFile = file;
          } else if (fileType == 'passport') {
            _passportFile = file;
          } else if (fileType == 'certificate') {
            if (_professionalCertificates.length < 5) {
              _professionalCertificates.add(file);
            } else {
              _showError('Maximum 5 certificates allowed');
            }
          }
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showError('Failed to pick file: $e');
    }
  }

  void _removeCertificate(int index) {
    setState(() {
      _professionalCertificates.removeAt(index);
    });
  }

  bool _validateDocuments() {
    if (_identityDocumentType == 'national_id' && _nationalIdFile == null) {
      _showError('Please upload your National ID document');
      return false;
    }
    if (_identityDocumentType == 'passport' && _passportFile == null) {
      _showError('Please upload your Passport document');
      return false;
    }
    if (_identityDocumentType == 'both' &&
        (_nationalIdFile == null || _passportFile == null)) {
      _showError('Please upload both National ID and Passport documents');
      return false;
    }
    if (_professionalCertificates.isEmpty) {
      _showError(widget.accountType == 'scout'
          ? 'Please upload at least one scouting certificate'
          : 'Please upload at least one coaching certificate');
      return false;
    }
    return true;
  }

  Future<void> _uploadDocuments() async {
    if (!_validateDocuments()) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      await _otpService.uploadVerificationDocuments(
        userId: widget.userId,
        accountType: widget.accountType,
        identityDocumentType: _identityDocumentType,
        nationalId: _nationalIdFile,
        passport: _passportFile,
        professionalCertificates: _professionalCertificates,
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showError('Upload failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        content: Text(
          widget.accountType == 'scout'
              ? 'Documents uploaded successfully!\n\nYour account will be reviewed by our team. You will receive an email notification once approved.'
              : 'Documents uploaded successfully!\n\nYou can now complete your profile.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onComplete();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.accountType == 'scout'
              ? 'Scout Verification Documents'
              : 'Coach Verification Documents',
        ),
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Information Card
                  Card(
                    color: AppColors.primaryBlue.withOpacity(0.1),
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
                              const Text(
                                'Required Documents',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '1. Identity Document: National ID or Passport\n'
                            '2. Professional Certificate(s): ${widget.accountType == 'scout' ? 'Scouting licenses or certifications' : 'Coaching licenses or certifications'}\n\n'
                            'Accepted formats: JPG, PNG, PDF (max 5MB per file)',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Identity Document Type Selection
                  const Text(
                    'Select Identity Document Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<String>(
                    title: const Text('National ID'),
                    value: 'national_id',
                    groupValue: _identityDocumentType,
                    onChanged: (value) {
                      setState(() {
                        _identityDocumentType = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Passport'),
                    value: 'passport',
                    groupValue: _identityDocumentType,
                    onChanged: (value) {
                      setState(() {
                        _identityDocumentType = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Both (National ID and Passport)'),
                    value: 'both',
                    groupValue: _identityDocumentType,
                    onChanged: (value) {
                      setState(() {
                        _identityDocumentType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // National ID Upload
                  if (_identityDocumentType == 'national_id' ||
                      _identityDocumentType == 'both')
                    _buildDocumentUploadSection(
                      title: 'National ID Document',
                      file: _nationalIdFile,
                      onTap: () => _pickFile('national_id'),
                      onRemove: () => setState(() => _nationalIdFile = null),
                    ),

                  // Passport Upload
                  if (_identityDocumentType == 'passport' ||
                      _identityDocumentType == 'both')
                    _buildDocumentUploadSection(
                      title: 'Passport Document',
                      file: _passportFile,
                      onTap: () => _pickFile('passport'),
                      onRemove: () => setState(() => _passportFile = null),
                    ),

                  const SizedBox(height: 24),

                  // Professional Certificates
                  const Text(
                    'Professional Certificates',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.accountType == 'scout'
                        ? 'Upload your scouting certificates, licenses, or relevant qualifications (1-5 documents)'
                        : 'Upload your coaching licenses, certifications, or relevant qualifications (1-5 documents)',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  // List of uploaded certificates
                  ..._professionalCertificates.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading:
                            Icon(Icons.file_present, color: AppColors.primaryBlue),
                        title: Text(
                          file.path.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeCertificate(index),
                        ),
                      ),
                    );
                  }).toList(),

                  // Add Certificate Button
                  if (_professionalCertificates.length < 5)
                    OutlinedButton.icon(
                      onPressed: () => _pickFile('certificate'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Certificate'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadDocuments,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
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
                          : const Text(
                              'Upload Documents',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDocumentUploadSection({
    required String title,
    required File? file,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (file == null)
          InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload, size: 48, color: AppColors.primaryBlue),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'JPG, PNG, or PDF (max 5MB)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(
                file.path.split('/').last,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text('Document uploaded'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
