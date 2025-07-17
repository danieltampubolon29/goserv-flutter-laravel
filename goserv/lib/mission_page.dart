import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  List missions = [];
  int userId = 0;
  final String baseUrl = 'http://127.0.0.1:8000/api';

  @override
  void initState() {
    super.initState();
    checkAccess();
  }

  Future<void> claimMission(int missionId, int point) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/missions/claim'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'mission_id': missionId,
          'point': point,
        }),
      );

      final jsonResponse = jsonDecode(response.body);
      
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        fetchMissionsWithProgress(); // Refresh missions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Mission berhasil diklaim'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Gagal klaim mission'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error klaim mission: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat mengklaim mission'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> checkAccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    userId = prefs.getInt('user_id') ?? 0;

    if (role != 'customer') {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      fetchMissionsWithProgress();
    }
  }

  Future<void> fetchMissionsWithProgress() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/missions/user/progress/$userId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            missions = jsonResponse['data'] ?? [];
          });
        } else {
          debugPrint("API Error: ${jsonResponse['message']}");
        }
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
        debugPrint("Response: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Widget missionCard(Map mission) {
    final String nama = mission['nama'] ?? 'Tanpa Nama';
    final int targetHarga = (mission['harga'] is int)
        ? mission['harga']
        : int.tryParse(mission['harga'].toString()) ?? 0;

    final int totalProgress = (mission['progress'] is int)
        ? mission['progress']
        : int.tryParse(mission['progress'].toString()) ?? 0;

    final bool claimed = mission['claimed'] == true;
    final String tanggalMulai = mission['tanggal_mulai'] ?? '-';
    final String tanggalSelesai = mission['tanggal_selesai'] ?? '-';
    final int point = mission['point'] ?? 0;
    final int missionId = mission['id'] ?? 0;

    final double percent = targetHarga == 0 ? 0 : totalProgress / targetHarga;
    final bool canClaim = !claimed && totalProgress >= targetHarga;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$point pts',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Progress: Rp ${totalProgress.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} / Rp ${targetHarga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                claimed ? Colors.green : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(percent * 100).toStringAsFixed(1)}% completed',
            style: TextStyle(
              fontSize: 12,
              color: claimed ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Periode:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '$tanggalMulai s/d $tanggalSelesai',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: canClaim ? () => claimMission(missionId, point) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: claimed
                      ? Colors.green
                      : (canClaim ? Colors.yellow.shade700 : Colors.grey.shade400),
                  foregroundColor: claimed
                      ? Colors.white
                      : (canClaim ? Colors.black : Colors.grey.shade600),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: claimed ? 0 : 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (claimed) const Icon(Icons.check, size: 16),
                    if (claimed) const SizedBox(width: 4),
                    Text(
                      claimed
                          ? 'Diklaim'
                          : (canClaim ? 'Klaim' : 'Belum Selesai'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
                    "GoServ - Mission",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => fetchMissionsWithProgress(),
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
              Expanded(
                child: missions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Tidak ada mission aktif",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchMissionsWithProgress,
                        child: ListView.builder(
                          itemCount: missions.length,
                          itemBuilder: (context, index) {
                            final mission = missions[index];
                            return missionCard(mission);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/history');
          } else if (index == 2) {
            // Already on mission page
          } else if (index == 3) {
            Navigator.pushNamed(context, '/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Mission'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}