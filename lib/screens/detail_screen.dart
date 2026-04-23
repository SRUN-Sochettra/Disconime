import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class DetailScreen extends StatefulWidget {
  final dynamic data;

  const DetailScreen({super.key, required this.data});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<dynamic> _recommendations = [];
  bool _isLoading = true;
  bool _hasError = false;

  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _hasMore) {
        _fetchMoreRecommendations();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecommendations() async {
    final malId = widget.data['mal_id'];
    if (malId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      return;
    }

    _currentPage = 1;
    _hasMore = true;

    try {
      final response = await http.get(Uri.parse('https://api.jikan.moe/v4/anime/$malId/recommendations?page=$_currentPage'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (mounted) {
          setState(() {
            _recommendations = decodedData['data'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _fetchMoreRecommendations() async {
    final malId = widget.data['mal_id'];
    if (malId == null) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final response = await http.get(Uri.parse('https://api.jikan.moe/v4/anime/$malId/recommendations?page=$_currentPage'));
      if (response.statusCode == 200) {
        final newData = json.decode(response.body)['data'] ?? [];
        if (mounted) {
          setState(() {
            if (newData.isEmpty) {
              _hasMore = false;
            } else {
              _recommendations.addAll(newData);
            }
            _isLoadingMore = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
            _hasMore = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

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
                  widget.data['images']?['jpg']?['large_image_url'] ?? '',
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
                        '> ${widget.data['title'] ?? 'UNKNOWN'}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '[STATUS]: ${widget.data['status'] ?? 'UNKNOWN'}',
                        style: GoogleFonts.spaceMono(color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 20),
                      Text(widget.data['synopsis'] ?? 'No synopsis available.'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _isLoading || _hasError || _recommendations.isEmpty 
                  ? '> Similar Series Not Found' 
                  : '> Similar Series',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            else if (!_hasError && _recommendations.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _recommendations.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _recommendations.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }

                    final recItem = _recommendations[index];
                    final rec = recItem['entry'];
                    if (rec == null) return const SizedBox.shrink();
                    
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
