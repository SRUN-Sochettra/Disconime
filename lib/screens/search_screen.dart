import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  Future<void> searchApi(String query) async {
    FocusScope.of(context).unfocus();
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/anime?q=$query&limit=10'));
    if (response.statusCode == 200) {
      setState(() {
        _searchResults = json.decode(response.body)['data'];
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Search'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                style: GoogleFonts.spaceMono(color: Theme.of(context).colorScheme.primary),
                decoration: InputDecoration(
                  labelText: '> Search Any Anime Series',
                  labelStyle: GoogleFonts.spaceMono(color: Theme.of(context).colorScheme.primary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                    onPressed: () => searchApi(_controller.text),
                  ),
                ),
                onSubmitted: searchApi,
              ),
              const SizedBox(height: 20),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              const Text("Type an anime name to start searching"),
                            ],
                          ),
                        )
                      : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Card(
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 1),
                                  borderRadius: BorderRadius.zero,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(data: item),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4),
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                                          ),
                                          child: Image.network(
                                            item['images']['jpg']['image_url'],
                                            width: 60,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '> ${item['title']}',
                                                style: Theme.of(context).textTheme.titleMedium,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '[SCORE]: ${item['score'] ?? 'N/A'}',
                                                style: Theme.of(context).textTheme.labelMedium,
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
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}