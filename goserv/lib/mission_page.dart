import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
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
        debugPrint("Gagal mengambil data (${response.statusCode})");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Widget missionCard(Map mission) {
    final String nama = mission['nama'] ?? 'Tanpa Nama';
    final int harga = mission['harga'] ?? 1;
    final int point = mission['point'] ?? 0;
    final String tanggalMulai = mission['tanggal_mulai'] ?? '-';
    final String tanggalSelesai = mission['tanggal_selesai'] ?? '-';
    final double percent = harga == 0 ? 0 : point / harga;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Nama Misi + Point (di kanan atas)
          Row(
            children: [
              // Nama misi (mengisi ruang sebisa mungkin)
              Expanded(
                child: Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Teks point biasa dengan warna kuning/gold
              Text(
                point.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      Colors
                          .orangeAccent, // kamu bisa ganti jadi Colors.yellow atau Colors.amber
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Harga (tetap di bawah nama)
          Text(
            "0 / $harga",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),

          const SizedBox(height: 12),

          // Tanggal dan Tombol Klaim
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$tanggalMulai sd $tanggalSelesai',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 2,
                ),
                child: const Text('Klaim'),
              ),
            ],
          ),
        ],
      ),
    );
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "GoServ - Mission",
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

              const SizedBox(height: 20),

              // Mission Cards
              Expanded(
                child:
                    missions.isEmpty
                        ? const Center(child: Text("Tidak ada data mission"))
                        : ListView.builder(
                          itemCount: missions.length,
                          itemBuilder: (context, index) {
                            final mission = missions[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: missionCard(mission),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/history');
          } else if (index != 3) {
            Navigator.pushNamed(context, '/mission');
          }
        },
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
