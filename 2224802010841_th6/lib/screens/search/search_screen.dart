import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../services/itunes_service.dart';
import '../../providers/audio_provider.dart';
import '../../models/song.dart';
import '../../widgets/song_tile.dart';
import '../player/player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _itunesService = ItunesService();
  final _searchController = TextEditingController();
  Timer? _debounce;
  
  List<Song> _searchResults = [];
  bool _isLoading = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    setState(() {
      _query = query;
    });

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    
    try {
      final results = await _itunesService.searchSongs(query);
      if (mounted && _query == query) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Search',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                itemColor: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5) ?? Colors.grey,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                placeholder: 'Artists, songs, or podcasts',
                placeholderStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.4)),
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: _query.trim().isEmpty
                  ? _buildCategories()
                  : _isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : _searchResults.isEmpty
                          ? Center(child: Text('No results found', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5))))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final song = _searchResults[index];
                                return SongTile(
                                  song: song,
                                  onTap: () {
                                    Provider.of<AudioProvider>(context, listen: false)
                                        .playSong(song, _searchResults);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      useSafeArea: true,
                                      builder: (context) => const PlayerScreen(),
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

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Browse Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              final colors = [
                Colors.pink, Colors.blue, Colors.orange, Colors.purple,
                Colors.teal, Colors.red, Colors.green, Colors.indigo
              ];
              return Container(
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                alignment: Alignment.topLeft,
                child: Text(
                  'Category ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
