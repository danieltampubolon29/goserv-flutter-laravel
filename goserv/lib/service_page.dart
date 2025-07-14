import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final String baseUrl = 'http://127.0.0.1:8000'; // Sesuaikan jika perlu
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchServices();
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
    final pointController = TextEditingController(
      text: existingData?['point']?.toString() ?? '',
    );
    List<TextEditingController> serviceControllers = [];
    if (existingData != null && existingData['service_items'] != null) {
      for (var item in existingData['service_items']) {
        serviceControllers.add(TextEditingController(text: item));
      }
    } else {
      serviceControllers.add(TextEditingController());
    }

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(index == null ? 'Tambah Service' : 'Edit Service'),
            content: StatefulBuilder(
              builder: (context, setModalState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Customer *',
                        ),
                      ),
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
                            setModalState(() {});
                          }
                        },
                      ),
                      TextField(
                        controller: kendaraanController,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Kendaraan *',
                        ),
                      ),
                      TextField(
                        controller: nopolController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Polisi *',
                        ),
                      ),
                      TextField(
                        controller: hargaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Harga *'),
                      ),
                      TextField(
                        controller: pointController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Point *'),
                      ),
                      const SizedBox(height: 10),
                      const Text("Service Items:"),
                      ...serviceControllers.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: TextField(
                            controller: c,
                            decoration: InputDecoration(
                              labelText: 'Jenis Service',
                            ),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setModalState(() {
                            serviceControllers.add(TextEditingController());
                          });
                        },
                        icon: Icon(Icons.add),
                        label: Text('Tambah Jenis Service'),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(ctx).pop,
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      dateController.text.isEmpty ||
                      kendaraanController.text.isEmpty ||
                      nopolController.text.isEmpty ||
                      hargaController.text.isEmpty ||
                      pointController.text.isEmpty ||
                      serviceControllers.every((c) => c.text.trim().isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Semua field wajib diisi!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final data = {
                    'customer_name': nameController.text,
                    'tanggal': dateController.text,
                    'jenis_kendaraan': kendaraanController.text,
                    'nomor_polisi': nopolController.text,
                    'harga': int.tryParse(hargaController.text) ?? 0,
                    'point': int.tryParse(pointController.text) ?? 0,
                    'service_items':
                        serviceControllers.map((c) => c.text).toList(),
                  };
                  try {
                    final url =
                        existingData == null
                            ? '$baseUrl/api/services'
                            : '$baseUrl/api/services/${existingData['id']}';
                    final response =
                        existingData == null
                            ? await http.post(
                              Uri.parse(url),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode(data),
                            )
                            : await http.put(
                              Uri.parse(url),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode(data),
                            );
                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      final jsonResponse = jsonDecode(response.body);
                      final service = jsonResponse['data'];
                      if (service['service_items'] is String) {
                        try {
                          final decoded = jsonDecode(service['service_items']);
                          service['service_items'] =
                              decoded is List ? decoded.cast<String>() : [];
                        } catch (e) {
                          service['service_items'] = [];
                        }
                      }
                      if (index != null) {
                        setState(() => _services[index] = service);
                      } else {
                        setState(() => _services.add(service));
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Data berhasil disimpan'),
                        ),
                      );
                      Navigator.pop(ctx);
                    }
                  } catch (e) {
                    print("Error saat mengirim data: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '⚠️ Terjadi kesalahan saat mengirim data',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          ),
    );
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
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
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
        // Show error alert dialog
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
                Text('Tanggal: ${service['tanggal']}'),
                Text('Kendaraan: ${service['jenis_kendaraan']}'),
                Text('No. Polisi: ${service['nomor_polisi']}'),
                Text('Harga: Rp ${service['harga']}'),
                Text('Point: ${service['point']}'),
                const SizedBox(height: 10),
                Text(
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
      Navigator.pushNamed(context, '/dashboard');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/service');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/history');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/mission');
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
                        icon: const Icon(Icons.search),
                        onPressed: () {},
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
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.edit_document), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}
