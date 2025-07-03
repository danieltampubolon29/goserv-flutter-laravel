import 'package:flutter/material.dart';
import 'package:goserv/dashboard_page.dart';
import 'package:goserv/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Laravel Login',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: checkLogin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return snapshot.data == true ? const DashboardPage() : const LoginPage();
              },
            ),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
