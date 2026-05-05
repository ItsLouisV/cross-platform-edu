import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deadline;
  final bool isPinned;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    this.updatedAt,
    this.deadline,
    this.isPinned = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'created_at': createdAt.toIso8601String(),
    'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'is_pinned': isPinned,
  };

  /// Create Note from Supabase JSON
  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null,
    deadline: json['deadline'] != null
        ? DateTime.parse(json['deadline'])
        : null,
    isPinned: json['is_pinned'] ?? false,
  );

  /// Create a copy with updated fields
  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    DateTime? deadline,
    bool? isPinned,
    bool clearDeadline = false,
  }) => Note(
    id: id,
    title: title ?? this.title,
    content: content ?? this.content,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    deadline: clearDeadline ? null : (deadline ?? this.deadline),
    isPinned: isPinned ?? this.isPinned,
  );

  @override
  String toString() => 'Note(id: $id, title: $title)';
}
