import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all notes (non-deleted), pinned first, then by created_at DESC
  static Future<List<Note>> fetchNotes() async {
    try {
      final response = await _client
          .from('notes')
          .select()
          .eq('is_deleted', false)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      rethrow;
    }
  }

  /// Create a new note
  static Future<Note> createNote(Note note) async {
    try {
      final data = note.toJson();
      // Add user_id from current session (placeholder for no-auth mode)
      // When using auth, replace with actual user id
      await _client.from('notes').insert(data);
      return note;
    } catch (e) {
      debugPrint('Error creating note: $e');
      rethrow;
    }
  }

  /// Update an existing note
  static Future<void> updateNote(Note note) async {
    try {
      await _client.from('notes').update(note.toJson()).eq('id', note.id);
    } catch (e) {
      debugPrint('Error updating note: $e');
      rethrow;
    }
  }

  /// Soft-delete a note (set is_deleted = true)
  static Future<void> deleteNote(String noteId) async {
    try {
      await _client.from('notes').update({'is_deleted': true}).eq('id', noteId);
    } catch (e) {
      debugPrint('Error deleting note: $e');
      rethrow;
    }
  }

  /// Search notes by title or content
  static Future<List<Note>> searchNotes(String query) async {
    try {
      final response = await _client
          .from('notes')
          .select()
          .eq('is_deleted', false)
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error searching notes: $e');
      rethrow;
    }
  }
}
