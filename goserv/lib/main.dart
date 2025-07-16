    import 'package:flutter/material.dart';
    import 'package:goserv/dashboard_admin_page.dart';
    import 'package:goserv/history_page.dart';
    import 'package:goserv/mission_admin_page.dart';
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
            '/dashboard_admin': (context) => const DashboardAdminPage(),
            '/mission': (context) => const MissionPage(),
            '/mission_admin': (context) => const MissionAdminPage(),
            '/service': (context) => const ServicePage(),
            '/history': (context) => const HistoryPage(), 
          },
        );
      }
    }
