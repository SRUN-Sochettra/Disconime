import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../main.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _data = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isFetchingMore && _hasMore) {
        fetchMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    _currentPage = 1;
    _hasMore = true;
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/top/anime?filter=airing&page=1&limit=15'));
    if (response.statusCode == 200) {
      setState(() {
        _data = json.decode(response.body)['data'];
        _isLoading = false;
      });
    }
  }

  Future<void> fetchMoreData() async {
    setState(() => _isFetchingMore = true);
    _currentPage++;
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/top/anime?filter=airing&page=$_currentPage&limit=15'));
    if (response.statusCode == 200) {
      final newData = json.decode(response.body)['data'];
      setState(() {
        if (newData.isEmpty) {
          _hasMore = false;
        } else {
          _data.addAll(newData);
        }
        _isFetchingMore = false;
      });
    } else {
      setState(() => _isFetchingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _data.length + (_isFetchingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _data.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final item = _data[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
}