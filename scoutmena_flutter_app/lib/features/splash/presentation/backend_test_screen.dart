import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/backend_integration.dart';
import '../../../core/constants/api_constants.dart';

/// Backend Integration Test Screen
/// Displays backend connection status and endpoint tests
class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({super.key});

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  late BackendIntegration _backendIntegration;
  bool _isLoading = false;
  Map<String, dynamic>? _statusData;
  Map<String, dynamic>? _endpointTests;

  @override
  void initState() {
    super.initState();
    _backendIntegration = BackendIntegration(const FlutterSecureStorage());
    _testBackend();
  }

  Future<void> _testBackend() async {
    setState(() => _isLoading = true);

    final status = await _backendIntegration.getBackendStatus();
    final endpoints = await _backendIntegration.testCriticalEndpoints();

    setState(() {
      _statusData = status;
      _endpointTests = endpoints;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Integration Test'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testBackend,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildConfigCard(),
                  const SizedBox(height: 16),
                  _buildEndpointsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    final isReachable = _statusData?['reachable'] ?? false;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isReachable ? Icons.check_circle : Icons.error,
                  color: isReachable ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  isReachable ? 'Backend Connected' : 'Backend Unreachable',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_statusData?['error'] != null) ...[
              const Text(
                'Error:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 4),
              Text(
                _statusData!['error'].toString(),
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            if (_statusData?['status_code'] != null) ...[
              const SizedBox(height: 8),
              Text('Status Code: ${_statusData!['status_code']}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildConfigRow('Base URL', ApiConstants.baseUrl),
            _buildConfigRow('API Version', ApiConstants.apiVersion),
            _buildConfigRow('Full URL', ApiConstants.apiBaseUrl),
            _buildConfigRow('Connect Timeout', '${ApiConstants.connectTimeout}ms'),
            _buildConfigRow('Receive Timeout', '${ApiConstants.receiveTimeout}ms'),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointsCard() {
    if (_endpointTests == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Endpoint Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._endpointTests!.entries.map((entry) {
              return _buildEndpointRow(entry.key, entry.value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEndpointRow(String name, dynamic data) {
    final isAvailable = data['available'] ?? false;
    final statusCode = data['status_code'];
    final method = data['method'] ?? '';
    final path = data['path'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAvailable ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: isAvailable ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (statusCode != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(statusCode),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusCode.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$method $path',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'monospace',
            ),
          ),
          if (data['error'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Error: ${data['error']}',
              style: const TextStyle(fontSize: 11, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return Colors.green;
    if (statusCode >= 400 && statusCode < 500) return Colors.orange;
    if (statusCode >= 500) return Colors.red;
    return Colors.grey;
  }
}
