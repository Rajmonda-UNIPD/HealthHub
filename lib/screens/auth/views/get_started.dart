import 'package:flutter/material.dart';
import 'dart:ui';

class GetStarted extends StatelessWidget {
  final VoidCallback onContinue;

  const GetStarted({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  height: MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: MediaQuery.of(context).size.width / 1.3,
                  width: MediaQuery.of(context).size.width / 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/img/Logo2.png',
                      width: 100,
                      height: 100,
                    ),
                    const Text(
                      'Welcome to HealthHub',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your all-in-one health companion. Track your wellness, manage conditions, and access expert advice effortlessly. Start your journey to better health.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Image.asset(
                      'assets/img/Doctore.png',
                      height: 400,
                      width: 300,
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 70, 130, 179),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
