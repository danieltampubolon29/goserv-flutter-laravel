import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _DataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> services;
  final BuildContext context;
  final Function({Map<String, dynamic>? existingData, int? index}) onEdit;
  final Function(int) onDelete;
  final Function(Map<String, dynamic>) onDetail;

  _DataTableSource(
    this.services,
    this.context,
    this.onEdit,
    this.onDelete,
    this.onDetail,
  );

  @override
  DataRow getRow(int index) {
    final service = services[index];
    return DataRow(
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(service['customer_name'])),
        DataCell(Text(service['jenis_kendaraan'])),
        DataCell(Text(service['nomor_polisi'])),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => onDetail(service),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onEdit(existingData: service, index: index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onDelete(index),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => services.length;

  @override
  int get selectedRowCount => 0;
}

class _ServicePageState extends State<ServicePage> {
  final List<Map<String, dynamic>> _services = [];
  String _searchQuery = '';
  final String baseUrl = 'http://127.0.0.1:8000';
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    checkAccess();
    _fetchServices();
  }

  Future<void> checkAccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    if (role != 'admin') {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _fetchServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/services'));
      if (response.statusCode == 200) {
        final List<dynamic> servicesJson = jsonDecode(response.body);
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
          _services.clear();
          _services.addAll(parsedServices);
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal memuat data')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  List<Map<String, dynamic>> _filteredServices() {
    if (_searchQuery.isEmpty) {
      return _services;
    }
    final query = _searchQuery.toLowerCase();
    return _services.where((item) {
      final name = item['customer_name'].toString().toLowerCase();
      final nopol = item['nomor_polisi'].toString().toLowerCase();
      return name.contains(query) || nopol.contains(query);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _searchCustomers(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/customers/search?query=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> customers = jsonDecode(response.body);
        return customers.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error searching customers: $e');
    }
    return [];
  }

  // Fungsi untuk mendapatkan total point user
  Future<int> _getUserPoints(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/points'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return int.tryParse(data['total_points'].toString()) ?? 0;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user points: $e');
    }
    return 0;
  }

  // Modal untuk tukar point
  void _showPointExchangeModal(Map<String, dynamic> serviceData) {
    bool usePoints = false;
    int userPoints = 0;
    int originalPrice = serviceData['harga'];
    int finalPrice = originalPrice;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setModalState) {
              return AlertDialog(
                title: const Text('Tukar Point'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer: ${serviceData['customer_name']}'),
                    const SizedBox(height: 16),
                    Text(
                      'Harga Service: Rp ${originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Point information
                    FutureBuilder<int>(
                      future: _getUserPoints(serviceData['user_id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        userPoints = snapshot.data ?? 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Point Tersedia: $userPoints'),
                            const SizedBox(height: 16),

                            // Toggle untuk menggunakan point
                            Row(
                              children: [
                                const Text('Gunakan Point: '),
                                Switch(
                                  value: usePoints,
                                  onChanged: (value) {
                                    setModalState(() {
                                      usePoints = value;
                                      if (usePoints) {
                                        int pointsToUse =
                                            userPoints > originalPrice
                                                ? originalPrice
                                                : userPoints;
                                        finalPrice =
                                            originalPrice - pointsToUse;
                                      } else {
                                        finalPrice = originalPrice;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),

                            if (usePoints) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Harga Awal: Rp ${originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                    ),
                                    Text(
                                      'Point Digunakan: ${userPoints > originalPrice ? originalPrice : userPoints}',
                                    ),
                                    const Divider(),
                                    Text(
                                      'Total Bayar: Rp ${finalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Siapkan data untuk dikirim
                      final finalServiceData = {
                        ...serviceData,
                        'final_price': finalPrice,
                        'points_used':
                            usePoints
                                ? (userPoints > originalPrice
                                    ? originalPrice
                                    : userPoints)
                                : 0,
                        'point':
                            usePoints
                                ? (userPoints > originalPrice
                                    ? originalPrice
                                    : userPoints)
                                : 0, // Point yang akan ditambahkan ke service
                      };

                      await _saveServiceData(finalServiceData);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Fungsi untuk menyimpan data service dengan point
  Future<void> _saveServiceData(Map<String, dynamic> data) async {
    try {
      final url = '$baseUrl/api/services';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchServices();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Service berhasil disimpan')),
        );
      } else {
        final errorBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${errorBody['message'] ?? 'Gagal menyimpan data'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Terjadi kesalahan saat menyimpan data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showServiceForm({Map<String, dynamic>? existingData, int? index}) {
    final nameController = TextEditingController(
      text: existingData?['customer_name'] ?? '',
    );
    final dateController = TextEditingController(
      text: existingData?['tanggal'] ?? '',
    );
    final kendaraanController = TextEditingController(
      text: existingData?['jenis_kendaraan'] ?? '',
    );
    final nopolController = TextEditingController(
      text: existingData?['nomor_polisi'] ?? '',
    );
    final hargaController = TextEditingController(
      text: existingData?['harga']?.toString() ?? '',
    );

    int? selectedUserId = existingData?['user_id'];
    bool isFormComplete = false;

    List<TextEditingController> serviceControllers = [];
    if (existingData != null && existingData['service_items'] != null) {
      for (var item in existingData['service_items']) {
        serviceControllers.add(TextEditingController(text: item));
      }
    } else {
      serviceControllers.add(TextEditingController());
    }

    List<Map<String, dynamic>> searchResults = [];
    Timer? searchTimer;
    bool isSearching = false;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setModalState) {
              // Check if form is complete
              void checkFormComplete() {
                isFormComplete =
                    nameController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    kendaraanController.text.isNotEmpty &&
                    nopolController.text.isNotEmpty &&
                    hargaController.text.isNotEmpty &&
                    selectedUserId != null &&
                    serviceControllers.any((c) => c.text.trim().isNotEmpty);
                setModalState(() {});
              }

              return AlertDialog(
                title: Text(index == null ? 'Tambah Service' : 'Edit Service'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Customer Name with Live Search
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Nama Customer *',
                              suffixIcon:
                                  isSearching
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              checkFormComplete();
                              if (selectedUserId != null &&
                                  value != existingData?['customer_name']) {
                                selectedUserId = null;
                              }

                              searchTimer?.cancel();
                              searchTimer = Timer(
                                const Duration(milliseconds: 500),
                                () async {
                                  if (value.isNotEmpty) {
                                    setModalState(() {
                                      isSearching = true;
                                    });

                                    final results = await _searchCustomers(
                                      value,
                                    );

                                    setModalState(() {
                                      searchResults = results;
                                      isSearching = false;
                                    });
                                  } else {
                                    setModalState(() {
                                      searchResults = [];
                                      isSearching = false;
                                    });
                                  }
                                },
                              );
                            },
                          ),

                          if (searchResults.isNotEmpty &&
                              selectedUserId == null)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                children:
                                    searchResults.map((customer) {
                                      return ListTile(
                                        title: Text(customer['name']),
                                        subtitle: Text('ID: ${customer['id']}'),
                                        onTap: () {
                                          nameController.text =
                                              customer['name'];
                                          selectedUserId = customer['id'];
                                          setModalState(() {
                                            searchResults = [];
                                          });
                                          checkFormComplete();
                                        },
                                      );
                                    }).toList(),
                              ),
                            ),
                        ],
                      ),

                      if (selectedUserId != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Customer dipilih: ${nameController.text} (ID: $selectedUserId)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal *',
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            dateController.text =
                                picked.toIso8601String().split('T').first;
                            checkFormComplete();
                          }
                        },
                      ),
                      TextField(
                        controller: kendaraanController,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Kendaraan *',
                        ),
                        onChanged: (_) => checkFormComplete(),
                      ),
                      TextField(
                        controller: nopolController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Polisi *',
                        ),
                        onChanged: (_) => checkFormComplete(),
                      ),
                      TextField(
                        controller: hargaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Harga *'),
                        onChanged: (_) => checkFormComplete(),
                      ),
                      const SizedBox(height: 10),
                      const Text("Service Items:"),
                      ...serviceControllers.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: c,
                                  decoration: const InputDecoration(
                                    labelText: 'Jenis Service',
                                  ),
                                  onChanged: (_) => checkFormComplete(),
                                ),
                              ),
                              if (serviceControllers.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      serviceControllers.remove(c);
                                    });
                                    checkFormComplete();
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setModalState(() {
                            serviceControllers.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Jenis Service'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      searchTimer?.cancel();
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Batal"),
                  ),
                  ElevatedButton(
                    onPressed:
                        !isFormComplete
                            ? null
                            : () {
                              if (index != null) {
                                // Edit mode - save directly
                                _updateService(existingData!, {
                                  'user_id': selectedUserId,
                                  'customer_name': nameController.text,
                                  'tanggal': dateController.text,
                                  'jenis_kendaraan': kendaraanController.text,
                                  'nomor_polisi': nopolController.text,
                                  'harga':
                                      int.tryParse(hargaController.text) ?? 0,
                                  'point': existingData['point'] ?? 0,
                                  'service_items':
                                      serviceControllers
                                          .where(
                                            (c) => c.text.trim().isNotEmpty,
                                          )
                                          .map((c) => c.text.trim())
                                          .toList(),
                                });
                                Navigator.of(ctx).pop();
                              } else {
                                // Add mode - prepare data for point exchange
                                final serviceData = {
                                  'user_id': selectedUserId,
                                  'customer_name': nameController.text,
                                  'tanggal': dateController.text,
                                  'jenis_kendaraan': kendaraanController.text,
                                  'nomor_polisi': nopolController.text,
                                  'harga':
                                      int.tryParse(hargaController.text) ?? 0,
                                  'service_items':
                                      serviceControllers
                                          .where(
                                            (c) => c.text.trim().isNotEmpty,
                                          )
                                          .map((c) => c.text.trim())
                                          .toList(),
                                };

                                searchTimer?.cancel();
                                Navigator.of(ctx).pop();
                                _showPointExchangeModal(serviceData);
                              }
                            },
                    child: Text(index == null ? "Lanjutkan" : "Simpan"),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Fungsi untuk update service (edit mode)
  Future<void> _updateService(
    Map<String, dynamic> existingData,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = '$baseUrl/api/services/${existingData['id']}';
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchServices();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Data berhasil diperbarui')),
        );
      } else {
        final errorBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${errorBody['message'] ?? 'Gagal memperbarui data'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Terjadi kesalahan saat memperbarui data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteService(int index) async {
    final service = _services[index];
    final url = '$baseUrl/api/services/${service['id']}';

    final action = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Hapus Service"),
            content: const Text("Apakah Anda yakin ingin menghapus data ini?"),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop("OK"),
                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (action != "OK") return;

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _services.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Data berhasil dihapus')),
        );
      } else {
        _showAlertDialog(
          context,
          'Gagal Menghapus',
          'Gagal menghapus data: ${response.body}',
        );
      }
    } catch (e) {
      _showAlertDialog(context, 'Error', 'Terjadi kesalahan: $e');
    }
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("Tutup"),
              ),
            ],
          ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(service['customer_name']),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User ID: ${service['user_id'] ?? 'N/A'}'),
                Text('Tanggal: ${service['tanggal']}'),
                Text('Kendaraan: ${service['jenis_kendaraan']}'),
                Text('No. Polisi: ${service['nomor_polisi']}'),
                Text('Harga: Rp ${service['harga']}'),
                Text('Point: ${service['point']}'),
                const SizedBox(height: 10),
                const Text(
                  'Service Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 4,
                  children:
                      (service['service_items'] as List)
                          .map((item) => Chip(label: Text(item)))
                          .toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("Tutup"),
              ),
            ],
          ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/dashboard_admin');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/mission_admin');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/service');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('GoServ - Service'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
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
                    "GoServ - Service",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _fetchServices,
                      ),
                      const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/logo_putih.png',
                        ),
                        radius: 20,
                        backgroundColor: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Cari berdasarkan Nama atau No. Polisi',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _services.isEmpty
                        ? const Center(child: Text('Belum ada data service.'))
                        : PaginatedDataTable(
                          columns: const [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('Nama')),
                            DataColumn(label: Text('Kendaraan')),
                            DataColumn(label: Text('No Polisi')),
                            DataColumn(label: Text('Aksi')),
                          ],
                          source: _DataTableSource(
                            _filteredServices(),
                            context,
                            _showServiceForm,
                            _deleteService,
                            _showDetailDialog,
                          ),
                          rowsPerPage: 5,
                          header: const Text('Daftar Service'),
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceForm(),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.edit_document), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}
