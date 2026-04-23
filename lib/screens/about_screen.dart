import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SYSTEM_ADMINS')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PROJECT IDENTIFIER:', style: Theme.of(context).textTheme.titleLarge),
            const Text('API Data Reader V1.0'),
            const SizedBox(height: 30),
            Text('OPERATIVES:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _buildMember('1. [Member Name 1]'),
            _buildMember('2. [Member Name 2]'),
            _buildMember('3. [Member Name 3]'),
            _buildMember('4. [Member Name 4]'),
          ],
        ),
      ),
    );
  }

  Widget _buildMember(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.account_tree, color: Colors.cyanAccent, size: 20),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}