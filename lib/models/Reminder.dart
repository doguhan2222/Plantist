import '../constants/Texts.dart';

class Reminder {
  String id;
  String title;
  String note;
  String priority;
  int dueDate;
  String category;
  List<String> tags;
  String attachmentUrl;

  Reminder({
    this.id = '',
    required this.title,
    required this.note,
    required this.priority,
    required this.dueDate,
    required this.category,
    required this.tags,
    required this.attachmentUrl,
  });

  factory Reminder.fromRTDB(Map<String, dynamic> data) {
    return Reminder(
      title: data['title'] ?? '',
      note: data['note'] ?? '',
      priority: data['priority'] ?? Texts.NOTIMPORTANT,
      dueDate: data['dueDate'] ?? 0,
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      attachmentUrl: data['attachmentUrl'] ?? '',
    );
  }

  Map<String, dynamic> toRTDB() {
    return {
      'title': title,
      'note': note,
      'priority': priority,
      'dueDate': dueDate,
      'category': category,
      'tags': tags,
      'attachmentUrl': attachmentUrl,
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? note,
    String? priority,
    int? dueDate,
    String? category,
    List<String>? tags,
    String? attachmentUrl,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}
