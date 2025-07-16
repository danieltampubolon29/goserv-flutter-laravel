import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedIndex = 1;
  List<Map<String, dynamic>> _history = [];
  final String baseUrl = 'http://127.0.0.1:8000'; // Sesuaikan IP jika perlu
  late String _token; // Simpan token Sanctum di sini

  @override
  void initState() {
    super.initState();
    _token = 'your-auth-token-here'; // Ganti dengan token yang valid
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/services/history'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> servicesJson = jsonResponse['data'];

        List<Map<String, dynamic>> parsedServices = [];

        for (var item in servicesJson) {
          if (item['service_items'] is String) {
            try {
              final decoded = jsonDecode(item['service_items']);
              item['service_items'] =
                  decoded is List ? decoded.cast<String>() : [];
            } catch (e) {
              item['service_items'] = [];
            }
          }
          parsedServices.add(item as Map<String, dynamic>);
        }

        setState(() {
          _history = parsedServices;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat riwayat: ${response.reasonPhrase}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 1) {
      // Index 1 adalah halaman saat ini (History), tidak perlu aksi.
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/mission');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(
        context,
        '/settings',
      ); 
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/logo_putih.png'),
                    backgroundColor: Colors.black,
                    radius: 20,
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
                    _history.isEmpty
                        ? const Center(
                          child: Text("Belum ada riwayat layanan."),
                        )
                        : ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(item['customer_name']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tanggal: ${item['tanggal']}'),
                                    Wrap(
                                      spacing: 4,
                                      children:
                                          (item['service_items'] as List)
                                              .map((s) => Chip(label: Text(s)))
                                              .toList(),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // Navigasi ke detail page (opsional)
                                },
                              ),
                            );
                          },
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}
