import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              decoration: InputDecoration(
                labelText: 'Search for an anime...',
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
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
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: Image.network(
                              item['images']['jpg']['image_url'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                            title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Score: ${item['score'] ?? 'N/A'}', style: Theme.of(context).textTheme.bodySmall),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(data: item),
                                ),
                              );
                            },
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