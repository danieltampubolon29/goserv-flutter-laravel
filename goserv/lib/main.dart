import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'dashboard_page.dart';
import 'mission_page.dart';
import 'service_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoServe',
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/mission': (context) => const MissionPage(),
        '/service': (context) => const ServicePage(),
      },
    );
  }
}
