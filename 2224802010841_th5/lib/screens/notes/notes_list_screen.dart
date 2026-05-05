import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import '../../providers/notes_provider.dart';
import '../../widgets/swipeable_note.dart';
import '../../constants/colors.dart';
import 'add_note_screen.dart';
import 'edit_note_screen.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(filteredNotesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: CustomScrollView(
        slivers: [
          // Large Title Navigation Bar (iOS style)
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Ghi chú'),
            backgroundColor: AppColors.background.withValues(alpha: 0.9),
            border: null,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _navigateToAddNote(context),
              child: const Icon(
                CupertinoIcons.plus_circle_fill,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() => _isSearching = !_isSearching);
                if (!_isSearching) {
                  ref.read(searchQueryProvider.notifier).state = '';
                }
              },
              child: Icon(
                _isSearching
                    ? CupertinoIcons.xmark_circle_fill
                    : CupertinoIcons.search,
                size: 22,
                color: AppColors.primary,
              ),
            ),
          ),

          // Search bar
          if (_isSearching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: CupertinoSearchTextField(
                  placeholder: 'Tìm kiếm ghi chú...',
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  autofocus: true,
                ),
              ),
            ),

          // Pull to refresh
          CupertinoSliverRefreshControl(
            onRefresh: () => ref.read(notesProvider.notifier).refresh(),
          ),

          // Notes count header
          if (notesAsync.hasValue && notesAsync.value!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Text(
                  searchQuery.isNotEmpty
                      ? '${notesAsync.value!.length} kết quả'
                      : '${notesAsync.value!.length} ghi chú',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Notes list / Loading / Error / Empty
          notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(searchQuery.isNotEmpty),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return SwipeableNote(
                    note: notes[index],
                    onDelete: (note) => _showDeleteConfirmation(context, note),
                    onTap: () => _navigateToEditNote(context, notes[index]),
                  );
                }, childCount: notes.length),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator(radius: 16)),
            ),
            error: (error, _) =>
                SliverFillRemaining(child: _buildErrorState(error.toString())),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearch) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch ? CupertinoIcons.search : CupertinoIcons.doc_text,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            isSearch ? 'Không tìm thấy ghi chú' : 'Chưa có ghi chú nào',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch ? 'Thử từ khóa khác' : 'Nhấn + để tạo ghi chú đầu tiên',
            style: const TextStyle(fontSize: 15, color: AppColors.textTertiary),
          ),
          if (!isSearch) ...[
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: () => _navigateToAddNote(context),
              borderRadius: BorderRadius.circular(12),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.plus, size: 18),
                  SizedBox(width: 6),
                  Text('Tạo ghi chú'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            size: 48,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),
          const Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
          CupertinoButton(
            onPressed: () => ref.read(notesProvider.notifier).refresh(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddNote(BuildContext context) {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (context) => const AddNoteScreen()));
  }

  void _navigateToEditNote(BuildContext context, Note note) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => EditNoteScreen(note: note)),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Note note) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Xóa ghi chú?'),
        content: Text(
          'Bạn có chắc muốn xóa "${note.title}"?\nHành động này không thể hoàn tác.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(note.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
