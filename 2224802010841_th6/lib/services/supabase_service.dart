import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Mock favorites state since we don't have DB setup yet
  final Set<String> _mockFavorites = {};

  // Authentication
  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  // Lấy danh sách bài hát (mock hoặc từ db)
  Future<List<Map<String, dynamic>>> getSongs() async {
    try {
      final response = await _client.from('songs').select().order('created_at', ascending: false);
      final list = List<Map<String, dynamic>>.from(response);
      if (list.isEmpty) {
        throw Exception('Empty table, use mock');
      }
      return list;
    } catch (e) {
      // Return mock data if table does not exist
      return [
        {
          'id': '1',
          'title': 'Lofi Study',
          'artist': 'FASSounds',
          'image_url': 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
          'stream_url': 'https://cdn.pixabay.com/audio/2022/05/27/audio_1808fbf07a.mp3',
          'duration_seconds': 145,
        },
        {
          'id': '2',
          'title': 'Good Night',
          'artist': 'FASSounds',
          'image_url': 'https://images.unsplash.com/photo-1493225457124-a1a2a5f5f923?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
          'stream_url': 'https://cdn.pixabay.com/audio/2022/03/15/audio_c8b828a1c9.mp3',
          'duration_seconds': 140,
        },
        {
          'id': '3',
          'title': 'Chill Vibes',
          'artist': 'Alex-Productions',
          'image_url': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
          'stream_url': 'https://cdn.pixabay.com/audio/2022/02/08/audio_c0eb2244f2.mp3',
          'duration_seconds': 150,
        }
      ];
    }
  }

  // Stream danh sách bài hát (Real-time updates)
  Stream<List<Map<String, dynamic>>> getSongsStream() {
    return _client
        .from('songs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  Future<String?> _getDbId(Song song) async {
    final uuidRegExp = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    if (uuidRegExp.hasMatch(song.id)) return song.id;

    // Check if it already exists
    final existing = await _client.from('songs')
        .select('id')
        .eq('title', song.title)
        .eq('artist', song.artist)
        .maybeSingle();

    return existing?['id'];
  }

  Future<String> _ensureSongInDb(Song song) async {
    final dbId = await _getDbId(song);
    if (dbId != null) return dbId;

    // Insert as new public_api song
    final res = await _client.from('songs').insert({
      'title': song.title,
      'artist': song.artist,
      'image_url': song.albumArtUrl,
      'stream_url': song.audioUrl,
      'duration_seconds': song.durationSeconds,
      'source': 'public_api',
    }).select('id').single();

    return res['id'];
  }

  Future<bool> isFavorite(Song song) async {
    if (currentUser == null) return false;
    final dbId = await _getDbId(song);
    if (dbId == null) return false;
    
    try {
      final response = await _client
          .from('favorites')
          .select()
          .eq('user_id', currentUser!.id)
          .eq('song_id', dbId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return _mockFavorites.contains(dbId);
    }
  }

  Future<void> toggleFavorite(Song song) async {
    if (currentUser == null) return;
    
    final dbId = await _ensureSongInDb(song);
    
    try {
      final isFav = await isFavorite(song);
      if (isFav) {
        await _client
            .from('favorites')
            .delete()
            .eq('user_id', currentUser!.id)
            .eq('song_id', dbId);
        _mockFavorites.remove(dbId);
      } else {
        await _client.from('favorites').insert({
          'user_id': currentUser!.id,
          'song_id': dbId,
        });
        _mockFavorites.add(dbId);
      }
    } catch (e) {
      if (_mockFavorites.contains(dbId)) {
        _mockFavorites.remove(dbId);
      } else {
        _mockFavorites.add(dbId);
      }
    }
  }

  Future<List<Map<String, dynamic>>> getFavoriteSongs() async {
    if (currentUser == null) return [];
    try {
      // Fetch favorites joined with songs
      final response = await _client
          .from('favorites')
          .select('songs(*)')
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(
        response.map((e) => e['songs']).where((s) => s != null),
      );
    } catch (e) {
      return [];
    }
  }

  Future<void> uploadSong({
    required String title,
    required String artist,
    required Uint8List fileBytes,
    required String extension,
    required int durationSeconds,
  }) async {
    if (currentUser == null) throw Exception('User not logged in');

    // Generate unique file name
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final filePath = 'mp3/$fileName';

    // 1. Upload to Storage
    await _client.storage.from('uploads').uploadBinary(
      filePath, 
      fileBytes,
      fileOptions: const FileOptions(upsert: true, contentType: 'audio/mpeg'),
    );

    // 2. Get Public URL
    final fileUrl = _client.storage.from('uploads').getPublicUrl(filePath);

    // 3. Insert into songs table
    await _client.from('songs').insert({
      'title': title,
      'artist': artist,
      'stream_url': fileUrl,
      'source': 'user_upload',
      'uploaded_by': currentUser!.id,
      'duration_seconds': durationSeconds,
      'image_url': 'https://images.unsplash.com/photo-1614149162883-504ce4d13909?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60', // Default image
    });
  }
  // ---------------------------------------------------------------------------
  // PLAYLISTS
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getPlaylists() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('playlists')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting playlists: $e');
      return [];
    }
  }

  Future<void> createPlaylist(String name) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('playlists').insert({
      'user_id': userId,
      'name': name,
    });
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    try {
      final dbId = await _ensureSongInDb(song);
      
      // Check if it already exists
      final existing = await _client
          .from('playlist_songs')
          .select()
          .eq('playlist_id', playlistId)
          .eq('song_id', dbId)
          .maybeSingle();

      if (existing == null) {
        await _client.from('playlist_songs').insert({
          'playlist_id': playlistId,
          'song_id': dbId,
        });
      }
    } catch (e) {
      debugPrint('Error adding song to playlist: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPlaylistSongs(String playlistId) async {
    try {
      // Join query to get songs for a playlist
      final response = await _client
          .from('playlist_songs')
          .select('songs(*)')
          .eq('playlist_id', playlistId)
          .order('order_index', ascending: true);

      // Extract the songs from the nested structure
      return List<Map<String, dynamic>>.from(response.map((e) => e['songs']).where((s) => s != null));
    } catch (e) {
      debugPrint('Error getting playlist songs: $e');
      return [];
    }
  }
}
