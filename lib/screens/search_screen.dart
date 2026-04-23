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
      appBar: AppBar(title: const Text('QUERY_DATABASE')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.cyanAccent),
              decoration: InputDecoration(
                labelText: 'Execute Search...',
                labelStyle: const TextStyle(color: Colors.cyanAccent),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.cyanAccent),
                  onPressed: () => searchApi(_controller.text),
                ),
              ),
              onSubmitted: searchApi,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return ListTile(
                          title: Text(item['title']),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.cyanAccent, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(data: item),
                              ),
                            );
                          },
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