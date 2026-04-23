import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project:', style: Theme.of(context).textTheme.titleLarge),
            const Text('API Data Reader V1.0'),
            const SizedBox(height: 30),
            Text('The Squad:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _buildMember(context, '1. [Member Name 1]'),
            _buildMember(context, '2. [Member Name 2]'),
            _buildMember(context, '3. [Member Name 3]'),
            _buildMember(context, '4. [Member Name 4]'),
          ],
        ),
      ),
    );
  }

  Widget _buildMember(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.account_tree, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}