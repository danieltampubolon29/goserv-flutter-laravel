import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedIndex = 1;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  String? _error;
  final String baseUrl = 'http://127.0.0.1:8000';
  int userId = 0;
  String? _token;

  @override
  void initState() {
    super.initState();
    checkAccess();
  }

  Future<void> checkAccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    userId = prefs.getInt('user_id') ?? 0;
    _token = prefs.getString(
      'token',
    ); // Assuming you store token in SharedPreferences

    if (role != 'customer') {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _fetchHistory();
    }
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Uri uri;
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      // Option 1: Using authenticated route (if you have token)
      if (_token != null && _token!.isNotEmpty) {
        uri = Uri.parse('$baseUrl/api/services/history');
        headers['Authorization'] = 'Bearer $_token';
      } else {
        // Option 2: Using user_id parameter route
        uri = Uri.parse('$baseUrl/api/services/history/$userId');
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> servicesJson = jsonResponse['data'];

          List<Map<String, dynamic>> parsedServices = [];

          for (var item in servicesJson) {
            // Handle service_items parsing
            if (item['service_items'] is String) {
              try {
                final decoded = jsonDecode(item['service_items']);
                item['service_items'] =
                    decoded is List ? decoded.cast<String>() : [];
              } catch (e) {
                item['service_items'] = [];
              }
            } else if (item['service_items'] is List) {
              item['service_items'] =
                  (item['service_items'] as List).cast<String>();
            } else {
              item['service_items'] = [];
            }

            parsedServices.add(item as Map<String, dynamic>);
          }

          setState(() {
            _history = parsedServices;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = jsonResponse['message'] ?? 'Failed to load history';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load history: ${response.reasonPhrase}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildServiceCard(Map<String, dynamic> item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['customer_name'] ?? 'Unknown Customer',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(item['tanggal'] ?? ''),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item['jenis_kendaraan']} - ${item['nomor_polisi']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (item['service_items'] != null &&
                (item['service_items'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Services:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children:
                        (item['service_items'] as List)
                            .map(
                              (service) => Chip(
                                label: Text(
                                  service.toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.blue.shade50,
                                labelStyle: TextStyle(
                                  color: Colors.blue.shade700,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  _formatCurrency(item['harga'] ?? 0),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 1) {
      // Current page - do nothing
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/mission');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/settings');
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "GoServ - History",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _fetchHistory,
                      ),
                      const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/logo_putih.png',
                        ),
                        backgroundColor: Colors.black,
                        radius: 20,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                "Riwayat Layanan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),

              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchHistory,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                        : _history.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "Belum ada riwayat layanan",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                        : RefreshIndicator(
                          onRefresh: _fetchHistory,
                          child: ListView.builder(
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              final item = _history[index];
                              return _buildServiceCard(item);
                            },
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Mission',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
