import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  List<Map<String, dynamic>> _services = [];
  final String baseUrl = 'http://127.0.0.1:8000'; // Ganti sesuai IP server kamu

  void _showServiceForm({Map<String, dynamic>? existingData, int? index}) {
    final nameController =
        TextEditingController(text: existingData?['customer_name'] ?? '');
    final dateController =
        TextEditingController(text: existingData?['tanggal'] ?? '');
    final kendaraanController =
        TextEditingController(text: existingData?['jenis_kendaraan'] ?? '');
    final nopolController =
        TextEditingController(text: existingData?['nomor_polisi'] ?? '');
    final hargaController = TextEditingController(
        text: existingData?['harga']?.toString() ?? '');
    final pointController = TextEditingController(
        text: existingData?['point']?.toString() ?? '');
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
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? 'Tambah Service' : 'Edit Service'),
        content: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama Customer')),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Tanggal'),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        dateController.text = picked.toIso8601String().split('T').first;
                      }
                    },
                  ),
                  TextField(
                      controller: kendaraanController,
                      decoration: const InputDecoration(labelText: 'Jenis Kendaraan')),
                  TextField(
                      controller: nopolController,
                      decoration: const InputDecoration(labelText: 'Nomor Polisi')),
                  TextField(
                      controller: hargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harga')),
                  TextField(
                      controller: pointController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Point')),
                  const SizedBox(height: 10),
                  const Text("Service Items:"),
                  ...serviceControllers.map((c) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: TextField(
                          controller: c,
                          decoration:
                              const InputDecoration(labelText: 'Jenis Service'),
                        ),
                      )),
                  TextButton.icon(
                    onPressed: () {
                      setModalState(() {
                        serviceControllers.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Jenis Service'),
                  )
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
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

              // Kirim ke API Laravel
              final response = await http.post(
                Uri.parse('$baseUrl/api/services'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(data),
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                final jsonResponse = jsonDecode(response.body);
                setState(() {
                  _services.add(jsonResponse['data']);
                });
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menyimpan data ke server')),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _deleteService(int index) {
    setState(() => _services.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Service Management'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _services.isEmpty
            ? const Center(child: Text('Belum ada data service.'))
            : ListView.builder(
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final item = _services[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['customer_name']),
                      subtitle:
                          Text('Rp ${item['harga']} - ${item['tanggal']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showServiceForm(existingData: item, index: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteService(index),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceForm(),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
