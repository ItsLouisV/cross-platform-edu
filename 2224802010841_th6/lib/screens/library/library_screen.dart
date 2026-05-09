// ignore_for_file: experimental_member_use

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../../services/supabase_service.dart';
import '../../utils/audio_url_helper.dart';
import 'playlist_detail_screen.dart';

class MyByteSource extends StreamAudioSource {
  final Uint8List _buffer;
  MyByteSource(this._buffer);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _buffer.length;
    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_buffer.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isUploading = false;
  List<Map<String, dynamic>> _playlists = [];
  int _favoriteCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final favs = await _supabaseService.getFavoriteSongs();
      final playlists = await _supabaseService.getPlaylists();
      
      if (mounted) {
        setState(() {
          _favoriteCount = favs.length;
          _playlists = playlists;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadSong() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.audio,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) return;

        final titleController = TextEditingController(text: file.name.split('.').first);
        final artistController = TextEditingController(text: 'Louis Artist');

        if (!mounted) return;

        final bool? confirm = await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Song Details'),
            content: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: titleController,
                    placeholder: 'Title',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    decoration: BoxDecoration(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: artistController,
                    placeholder: 'Artist',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    decoration: BoxDecoration(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Upload'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (confirm != true) return;

        setState(() => _isUploading = true);

        int durationSeconds = 0;
        try {
          final player = AudioPlayer();
          // Sử dụng Helper để lấy URL phù hợp cho từng nền tảng (Blob cho Web, Data URI cho Mobile)
          final audioUrl = await AudioUrlHelper.getAudioUrl(file.bytes!);
          final dur = await player.setUrl(audioUrl);
          durationSeconds = dur?.inSeconds ?? 0;
          await player.dispose();
        } catch (e) {
          debugPrint('Could not extract duration locally: $e');
        }

        await _supabaseService.uploadSong(
          title: titleController.text.trim(),
          artist: artistController.text.trim(),
          fileBytes: file.bytes!,
          extension: file.extension ?? 'mp3',
          durationSeconds: durationSeconds,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload successful!')),
          );
        }
        debugPrint('Upload successful!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
        debugPrint('Upload failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _createNewPlaylist() {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Tạo danh sách phát mới'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Tên danh sách phát',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                await _supabaseService.createPlaylist(name);
                await _loadData();
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: icon,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 14)),
      trailing: Icon(CupertinoIcons.chevron_right, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.2), size: 20),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              heroTag: 'library_nav_bar',
              largeTitle: const Text('Your Library'),
              backgroundColor: Colors.transparent,
              border: null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(CupertinoIcons.plus, color: Theme.of(context).iconTheme.color),
                    onPressed: _createNewPlaylist,
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.refresh, color: Theme.of(context).iconTheme.color),
                    onPressed: _loadData,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: CupertinoButton(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _isUploading ? null : _uploadSong,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isUploading 
                          ? const CupertinoActivityIndicator(color: Colors.white) 
                          : const Icon(CupertinoIcons.cloud_upload, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        _isUploading ? 'Uploading...' : 'Upload MP3', 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: Divider(color: Theme.of(context).dividerColor)),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CupertinoActivityIndicator()),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      // Liked Songs
                      return _buildPlaylistItem(
                        context: context,
                        title: 'Liked Songs',
                        subtitle: '$_favoriteCount songs',
                        icon: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(CupertinoIcons.heart_fill, color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlaylistDetailScreen(isFavorites: true),
                            ),
                          );
                        },
                      );
                    }
                    
                    // User Playlists
                    final playlist = _playlists[index - 1];
                    return _buildPlaylistItem(
                      context: context,
                      title: playlist['name'],
                      subtitle: 'Playlist',
                      icon: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(CupertinoIcons.music_note_list, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5)),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaylistDetailScreen(playlist: playlist),
                          ),
                        );
                      },
                    );
                  },
                  childCount: _playlists.length + 1, // +1 for Liked Songs
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)), // Bottom padding
          ],
        ),
      ),
    );
  }
}

