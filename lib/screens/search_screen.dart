import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import '../widgets/anime_image.dart';
import '../widgets/error_view.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<AnimeProvider>();
      if (provider.searchState != FetchState.loading &&
          _controller.text.isNotEmpty) {
        provider.searchAnime(_controller.text, loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    FocusScope.of(context).unfocus();
    if (query.isNotEmpty) {
      context.read<AnimeProvider>().searchAnime(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('SYS.SEARCH'),
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
              // ── Search field ──────────────────────────────────
              TextField(
                controller: _controller,
                style: GoogleFonts.spaceMono(
                  color: Theme.of(context).colorScheme.primary,
                ),
                decoration: InputDecoration(
                  labelText: '> INPUT QUERY',
                  labelStyle: GoogleFonts.spaceMono(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => _performSearch(_controller.text),
                  ),
                ),
                onSubmitted: _performSearch,
              ),
              const SizedBox(height: 20),

              // ── Results area ──────────────────────────────────
              Expanded(
                child: Consumer<AnimeProvider>(
                  builder: (context, provider, child) {
                    // Awaiting first input.
                    if (provider.searchState == FetchState.initial) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(76),
                            ),
                            const SizedBox(height: 16),
                            const Text("> AWAITING_INPUT"),
                          ],
                        ),
                      );
                    }

                    // Full screen loader — first page only.
                    if (provider.searchState == FetchState.loading &&
                        provider.searchResults.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }

                    // Full screen error — no results to show at all.
                    if (provider.searchState == FetchState.error &&
                        provider.searchResults.isEmpty) {
                      return ErrorView(
                        message: provider.errorMessage,
                        onRetry: () =>
                            provider.searchAnime(_controller.text),
                      );
                    }

                    // Empty results state.
                    if (provider.searchState == FetchState.loaded &&
                        provider.searchResults.isEmpty) {
                      return const Center(
                          child: Text('[NO_RECORDS_FOUND]'));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: provider.searchResults.length +
                          // Extra slot for loader or inline error.
                          (provider.searchState == FetchState.loading ||
                                  provider.searchState == FetchState.error
                              ? 1
                              : 0),
                      itemBuilder: (context, index) {
                        // ── Bottom loader ─────────────────────
                        if (index == provider.searchResults.length &&
                            provider.searchState == FetchState.loading) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        }

                        // ── Inline load-more error with retry ─
                        if (index == provider.searchResults.length &&
                            provider.searchState == FetchState.error) {
                          return ErrorView(
                            message: provider.errorMessage,
                            onRetry: () => provider.searchAnime(
                              _controller.text,
                              loadMore: true,
                            ),
                            expand: false,
                          );
                        }

                        final Anime item = provider.searchResults[index];
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          child: ClipRect(
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailScreen(anime: item),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withAlpha(100),
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 1,
                                            ),
                                          ),
                                          child: AnimeImage(
                                            imageUrl: item.imageUrl,
                                            size: AnimeImageSize.small,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '> ${item.title}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '[SCORE]: ${item.score.value ?? 'N/A'}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium,
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