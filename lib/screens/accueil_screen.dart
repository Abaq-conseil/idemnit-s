import 'package:flutter/material.dart';


class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indemnités'),
      ),
      body: const Center(
        child: Text(
          'Bienvenue dans Indemnités',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}