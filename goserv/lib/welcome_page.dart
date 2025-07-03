import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/logo_hitam.png', height: 400), 
              const SizedBox(height: 200),

              MouseRegion(
                onEnter: (_) => setState(() => isHovering = true),
                onExit: (_) => setState(() => isHovering = false),
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: isHovering
                      ? Matrix4.translationValues(0, -5, 0)
                      : Matrix4.identity(),
                  decoration: BoxDecoration(
                    color: isHovering ? Colors.grey[700] : Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isHovering
                        ? [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10), 
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Get Started',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
