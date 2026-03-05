// lib/pages/test_connection.dart - CORRECTED VERSION
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;

class TestConnectionPage extends StatefulWidget {
  const TestConnectionPage({super.key});

  @override
  _TestConnectionPageState createState() => _TestConnectionPageState();
}

class _TestConnectionPageState extends State<TestConnectionPage> {
  bool _isTesting = false;
  String _result = '';
  String _status = '';
  Color _statusColor = Colors.grey;

  final ApiService _apiService = ApiService();

  Future<void> _testBackendConnection() async {
    setState(() {
      _isTesting = true;
      _result = 'Testing connection...';
      _status = '';
      _statusColor = Colors.orange;
    });

    try {
      final result = await _apiService.testConnection();

      setState(() {
        _isTesting = false;

        if (result['success'] == true) {
          _result = '✅ ${result['message']}';
          _status = 'Status: ${result['status']}';
          _statusColor = Colors.green;
        } else {
          _result = '❌ ${result['message']}';
          _status = 'Status: ${result['status']}';
          _statusColor = Colors.red;
        }
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _result = '❌ Error: ${e.toString()}';
        _statusColor = Colors.red;
      });
    }
  }

  Future<void> _testAuthEndpoints() async {
    setState(() {
      _isTesting = true;
      _result = 'Testing auth endpoints...';
      _status = '';
      _statusColor = Colors.orange;
    });

    try {
      // Test GET /api/auth/me (should fail without token)
      final testUrl = Uri.parse('${ApiService.baseUrl}/auth/me');

      // Create a new http client for testing
      final response = await http.get(
        testUrl,
        headers: {'Accept': 'application/json'},
      );

      setState(() {
        _isTesting = false;
        _result = 'Auth endpoint response: ${response.statusCode}';
        _status = 'Expected 401 (Unauthorized) without token';
        _statusColor =
            response.statusCode == 401 ? Colors.green : Colors.orange;
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _result = '❌ Error testing auth: ${e.toString()}';
        _statusColor = Colors.red;
      });
    }
  }

  void _clearResult() {
    setState(() {
      _result = '';
      _status = '';
      _statusColor = Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Backend Connection'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backend URL info
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backend Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Base URL: ${ApiService.baseUrl}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Status: ${_isTesting ? 'Testing...' : 'Ready'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _testBackendConnection,
                    icon: const Icon(Icons.wifi),
                    label: const Text('Test Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _testAuthEndpoints,
                    icon: const Icon(Icons.security),
                    label: const Text('Test Auth'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _clearResult,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Results'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),

            const SizedBox(height: 20),

            // Results section
            Expanded(
              child: Card(
                elevation: 3,
                color: _statusColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_isTesting)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      if (_result.isNotEmpty) ...[
                        Text(
                          _result,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _statusColor,
                          ),
                        ),
                        if (_status.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            _status,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          'Troubleshooting Tips:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_statusColor == Colors.red)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                  '1. Check if backend server is running'),
                              const Text('2. Verify the base URL in .env file'),
                              const Text('3. Check your internet connection'),
                              const Text(
                                  '4. Ensure CORS is enabled on backend'),
                              const SizedBox(height: 10),
                              Text(
                                'Current URL: ${ApiService.baseUrl}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  backgroundColor: Colors.black12,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        else if (_statusColor == Colors.green)
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('✅ Backend is running correctly'),
                              Text('✅ API endpoints are accessible'),
                              Text('✅ Ready for authentication'),
                            ],
                          ),
                      ] else if (!_isTesting) ...[
                        const Spacer(),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Click "Test Connection" to check',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'if your backend is running',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Instructions
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('1. Start your Node.js backend server'),
                    Text('2. Click "Test Connection" button'),
                    Text('3. Green status means backend is accessible'),
                    Text('4. Red status means connection failed'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
