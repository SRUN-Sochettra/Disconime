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
                  Text('> PROJECT_INFO', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  const Text('  [NAME] Disconime'),
                  const SizedBox(height: 30),
                  Text('> SQUAD_ROSTER', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  _buildMember(context, '1. [Srun Sochettra]'),
                  _buildMember(context, '2. [Member Name 2]'),
                  _buildMember(context, '3. [Member Name 3]'),
                  _buildMember(context, '4. [Member Name 4]'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMember(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.terminal, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Text(name, style: GoogleFonts.spaceMono(fontSize: 16)),
        ],
      ),
    );
  }
}