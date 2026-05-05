import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import '../../providers/notes_provider.dart';
import '../../constants/colors.dart';
import '../../utils/date_formatter.dart';

class EditNoteScreen extends ConsumerStatefulWidget {
  final Note note;

  const EditNoteScreen({super.key, required this.note});

  @override
  ConsumerState<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends ConsumerState<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime? _deadline;
  bool _isPinned = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _deadline = widget.note.deadline;
    _isPinned = widget.note.isPinned;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updateNote() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('Vui lòng nhập tiêu đề');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedNote = widget.note.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        deadline: _deadline,
        isPinned: _isPinned,
        clearDeadline: _deadline == null,
      );

      await ref.read(notesProvider.notifier).updateNote(updatedNote);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Không thể cập nhật ghi chú: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Sửa ghi chú'),
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        border: null,
        previousPageTitle: 'Quay lại',
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _updateNote,
          child: _isLoading
              ? const CupertinoActivityIndicator()
              : const Text(
                  'Lưu',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status and Pin
            _buildSection(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cập nhật: ${DateFormatter.formatFullDate(widget.note.updatedAt ?? widget.note.createdAt)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Ghim',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoSwitch(
                          value: _isPinned,
                          activeTrackColor: AppColors.primary,
                          onChanged: (value) => setState(() => _isPinned = value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title field
            _buildSection(
              child: CupertinoTextField(
                controller: _titleController,
                placeholder: 'Tiêu đề',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                maxLines: 1,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 12),

            // Content field
            _buildSection(
              child: CupertinoTextField(
                controller: _contentController,
                placeholder: 'Nội dung ghi chú...',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                minLines: 8,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 12),

            // Deadline picker
            _buildSection(
              child: GestureDetector(
                onTap: _selectDeadline,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        size: 22,
                        color: _deadline != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _deadline != null
                              ? 'Hạn: ${DateFormatter.formatFullDate(_deadline!)}'
                              : 'Đặt deadline (tùy chọn)',
                          style: TextStyle(
                            fontSize: 16,
                            color: _deadline != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (_deadline != null)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          onPressed: () => setState(() => _deadline = null),
                          child: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: 20,
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  void _selectDeadline() {
    DateTime tempDate =
        _deadline ?? DateTime.now().add(const Duration(days: 1));

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.separator, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Text(
                    'Chọn deadline',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() => _deadline = tempDate);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Xong',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: tempDate,
                minimumDate: DateTime.now(),
                use24hFormat: true,
                onDateTimeChanged: (DateTime value) {
                  tempDate = value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
