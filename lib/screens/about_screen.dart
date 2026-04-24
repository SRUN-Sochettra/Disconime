import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('SYS.ABOUT'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, kToolbarHeight + 40, 24.0, 24.0),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4),
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('> SYSTEM_INFO', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  _buildInfoRow(context, 'App Name:', 'Disconime'),
                  _buildInfoRow(context, 'Version:', '1.0.0+1'),
                  _buildInfoRow(context, 'Developer:', 'SRUN-Sochettra'),
                  _buildInfoRow(context, 'Architecture:', 'Enterprise Layered'),
                  _buildInfoRow(context, 'Theme:', 'Cyber-Minimalist'),
                  const SizedBox(height: 30),
                  Text('> DEPENDENCIES', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  _buildDependency(context, 'provider'),
                  _buildDependency(context, 'http'),
                  _buildDependency(context, 'google_fonts'),
                  _buildDependency(context, 'flutter_dotenv'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: GoogleFonts.spaceMono(color: Theme.of(context).colorScheme.primary, fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.spaceMono(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildDependency(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.terminal, color: Theme.of(context).colorScheme.primary, size: 16),
          const SizedBox(width: 10),
          Text(name, style: GoogleFonts.spaceMono(fontSize: 14)),
        ],
      ),
    );
  }
}