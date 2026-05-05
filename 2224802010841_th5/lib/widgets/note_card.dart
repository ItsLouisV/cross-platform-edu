import 'package:flutter/cupertino.dart';
import '../models/note.dart';
import '../utils/date_formatter.dart';
import '../constants/colors.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with pin indicator
          Row(
            children: [
              if (note.isPinned) ...[
                const Icon(
                  CupertinoIcons.pin_fill,
                  size: 14,
                  color: AppColors.pinned,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Content preview
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Footer: created date + deadline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Created date
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.clock,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatCreatedDate(note.createdAt),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Deadline badge
              if (note.deadline != null) _buildDeadlineBadge(note.deadline!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineBadge(DateTime deadline) {
    final isOverdue = DateFormatter.isOverdue(deadline);
    final bgColor = isOverdue
        ? AppColors.destructive.withValues(alpha: 0.1)
        : AppColors.warning.withValues(alpha: 0.1);
    final textColor = isOverdue ? AppColors.destructive : AppColors.warning;
    final icon = isOverdue
        ? CupertinoIcons.exclamationmark_circle_fill
        : CupertinoIcons.calendar;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            DateFormatter.formatDeadline(deadline),
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
