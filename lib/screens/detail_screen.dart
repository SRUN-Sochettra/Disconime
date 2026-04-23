import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailScreen extends StatelessWidget {
  final dynamic data;

  const DetailScreen({super.key, required this.data});

  List<Map<String, dynamic>> get _mockRecommendations => [
    {
      'title': 'Cyber City Oedo 808',
      'score': 7.4,
      'status': 'Finished Airing',
      'synopsis': 'Three criminals are offered a deal: serve time or become cyber-police.',
      'images': {
        'jpg': {
          'large_image_url': 'https://cdn.myanimelist.net/images/anime/13/50521l.jpg',
          'image_url': 'https://cdn.myanimelist.net/images/anime/13/50521.jpg'
        }
      }
    },
    {
      'title': 'Akira',
      'score': 8.1,
      'status': 'Finished Airing',
      'synopsis': 'A secret military project endangers Neo-Tokyo.',
      'images': {
        'jpg': {
          'large_image_url': 'https://cdn.myanimelist.net/images/anime/13/17405l.jpg',
          'image_url': 'https://cdn.myanimelist.net/images/anime/13/17405.jpg'
        }
      }
    },
    {
      'title': 'Ghost in the Shell',
      'score': 8.2,
      'status': 'Finished Airing',
      'synopsis': 'A cyborg policewoman and her partner hunt a mysterious and powerful hacker.',
      'images': {
        'jpg': {
          'large_image_url': 'https://cdn.myanimelist.net/images/anime/10/82594l.jpg',
          'image_url': 'https://cdn.myanimelist.net/images/anime/10/82594.jpg'
        }
      }
    },
    {
      'title': 'Ergo Proxy',
      'score': 7.9,
      'status': 'Finished Airing',
      'synopsis': 'In a utopian dome city, humans and cyborgs coexist until a virus causes androids to become self-aware.',
      'images': {
        'jpg': {
          'large_image_url': 'https://cdn.myanimelist.net/images/anime/11/73428l.jpg',
          'image_url': 'https://cdn.myanimelist.net/images/anime/11/73428.jpg'
        }
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Series Info'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, kToolbarHeight + 40, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                child: Image.network(
                  data['images']?['jpg']?['large_image_url'] ?? '',
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ClipRect(
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
                      Text(
                        '> ${data['title'] ?? 'UNKNOWN'}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '[STATUS]: ${data['status'] ?? 'UNKNOWN'}',
                        style: GoogleFonts.spaceMono(color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 20),
                      Text(data['synopsis'] ?? 'No synopsis available.'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '> RELATED_DATA_FOUND',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _mockRecommendations.length,
                itemBuilder: (context, index) {
                  final rec = _mockRecommendations[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(data: rec),
                        ),
                      );
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 16),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4),
                              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Image.network(
                                      rec['images']?['jpg']?['image_url'] ?? rec['images']?['jpg']?['large_image_url'] ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rec['title'] ?? 'UNKNOWN',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '[${rec['score'] ?? 'N/A'}]',
                                        style: GoogleFonts.spaceMono(color: Theme.of(context).colorScheme.primary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}