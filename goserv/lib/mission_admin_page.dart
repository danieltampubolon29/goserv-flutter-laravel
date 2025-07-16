import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MissionAdminPage extends StatefulWidget {
  const MissionAdminPage({super.key});

  @override
  State<MissionAdminPage> createState() => _MissionAdminPageState();
}

class _MissionAdminPageState extends State<MissionAdminPage> {
  int _selectedIndex = 2;
  List missions = [];
  final String apiUrl = 'http://127.0.0.1:8000/api/missions';

  @override
  void initState() {
    super.initState();
    fetchMissions();
  }

  Future<void> fetchMissions() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          missions = jsonResponse['data'] ?? [];
        });
      } else {
        showError('Gagal mengambil data missions (${response.statusCode})');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void showForm({Map? mission}) {
    final namaController = TextEditingController(text: mission?['nama'] ?? '');
    final hargaController = TextEditingController(
      text: mission?['harga']?.toString() ?? '',
    );
    final pointController = TextEditingController(
      text: mission?['point']?.toString() ?? '',
    );
    final mulaiController = TextEditingController(
      text: mission?['tanggal_mulai'] ?? '',
    );
    final selesaiController = TextEditingController(
      text: mission?['tanggal_selesai'] ?? '',
    );
    String status = mission?['status'] ?? 'pending';

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    mission == null ? 'Tambah Mission' : 'Edit Mission',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: namaController,
                          decoration: const InputDecoration(labelText: 'Nama'),
                        ),
                        TextField(
                          controller: hargaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Harga'),
                        ),
                        TextField(
                          controller: pointController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Point'),
                        ),
                        TextField(
                          controller: mulaiController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Mulai',
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              mulaiController.text =
                                  picked.toIso8601String().split('T').first;
                            }
                          },
                        ),
                        TextField(
                          controller: selesaiController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Selesai',
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              selesaiController.text =
                                  picked.toIso8601String().split('T').first;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButton<String>(
                          value: status,
                          onChanged: (value) {
                            if (value != null) setState(() => status = value);
                          },
                          items:
                              ['pending', 'aktif', 'selesai']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed:
                          () => saveMission(
                            mission,
                            namaController,
                            hargaController,
                            pointController,
                            mulaiController,
                            selesaiController,
                            status,
                          ),
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> saveMission(
    Map? mission,
    TextEditingController namaController,
    TextEditingController hargaController,
    TextEditingController pointController,
    TextEditingController mulaiController,
    TextEditingController selesaiController,
    String status,
  ) async {
    if (namaController.text.isEmpty ||
        mulaiController.text.isEmpty ||
        selesaiController.text.isEmpty) {
      showError('Harap lengkapi semua kolom.');
      return;
    }

    final data = {
      'nama': namaController.text,
      'harga': int.tryParse(hargaController.text) ?? 0,
      'point': int.tryParse(pointController.text) ?? 0,
      'tanggal_mulai': mulaiController.text,
      'tanggal_selesai': selesaiController.text,
      'status': status,
    };

    try {
      final url = mission == null ? apiUrl : '$apiUrl/${mission['id']}';
      final response =
          mission == null
              ? await http.post(
                Uri.parse(url),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode(data),
              )
              : await http.put(
                Uri.parse(url),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode(data),
              );

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        Navigator.pop(context);
        fetchMissions();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Data berhasil disimpan'),
          ),
        );
      } else {
        showError(jsonResponse['message'] ?? 'Gagal menyimpan data');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  Future<void> deleteMission(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        fetchMissions();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jsonResponse['message'] ?? 'Mission berhasil dihapus',
            ),
          ),
        );
      } else {
        showError(jsonResponse['message'] ?? 'Gagal menghapus mission');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/dashboard_admin');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/service');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/mission_admin');
    }
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
                children: const [
                  Text(
                    "GoServ - Admin Mission",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/logo_putih.png'),
                    radius: 20,
                    backgroundColor: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    missions.isEmpty
                        ? const Center(child: Text('Belum ada data mission.'))
                        : ListView.builder(
                          itemCount: missions.length,
                          itemBuilder: (context, index) {
                            final item = missions[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  item['nama'] ?? 'Nama tidak tersedia',
                                ),
                                subtitle: Text(
                                  '${item['tanggal_mulai']} - ${item['tanggal_selesai']} (${item['status']})',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => showForm(mission: item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed:
                                          () => deleteMission(item['id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
