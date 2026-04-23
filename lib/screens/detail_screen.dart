import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final dynamic data;

  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RECORD_DETAILS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                ),
                child: Image.network(data['images']['jpg']['large_image_url']),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              data['title'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Status: ${data['status']}',
              style: const TextStyle(color: Colors.cyanAccent),
            ),
            const SizedBox(height: 20),
            Text(data['synopsis'] ?? 'No synopsis available.'),
          ],
        ),
      ),
    );
  }
}