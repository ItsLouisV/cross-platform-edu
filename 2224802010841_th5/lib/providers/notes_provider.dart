import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/supabase_service.dart';

/// Notifier class that manages the notes list state
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    return SupabaseService.fetchNotes();
  }

  /// Add a new note and refresh the list
  Future<void> addNote(Note note) async {
    state = const AsyncLoading();
    try {
      await SupabaseService.createNote(note);
      state = AsyncData(await SupabaseService.fetchNotes());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Update a note and refresh the list
  Future<void> updateNote(Note note) async {
    state = const AsyncLoading();
    try {
      await SupabaseService.updateNote(note);
      state = AsyncData(await SupabaseService.fetchNotes());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Delete a note and refresh the list
  Future<void> deleteNote(String noteId) async {
    state = const AsyncLoading();
    try {
      await SupabaseService.deleteNote(noteId);
      state = AsyncData(await SupabaseService.fetchNotes());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Refresh the notes list
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await SupabaseService.fetchNotes());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Main provider for the notes list
final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

/// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered notes based on search query
final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final notesAsync = ref.watch(notesProvider);

  if (query.isEmpty) return notesAsync;

  return notesAsync.whenData(
    (notes) => notes
        .where(
          (note) =>
              note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query),
        )
        .toList(),
  );
});
