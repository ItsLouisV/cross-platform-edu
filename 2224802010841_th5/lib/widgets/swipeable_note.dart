import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/note.dart';
import '../constants/colors.dart';
import 'note_card.dart';

class SwipeableNote extends StatelessWidget {
  final Note note;
  final Function(Note) onDelete;
  final VoidCallback? onTap;

  const SwipeableNote({
    super.key,
    required this.note,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(note.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(note),
            backgroundColor: AppColors.destructive,
            foregroundColor: CupertinoColors.white,
            icon: CupertinoIcons.trash_fill,
            label: 'Xóa',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: NoteCard(note: note),
      ),
    );
  }
}
