// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AddContentProgress {
  final double? progress;
  final String? filePath;
  final bool completed;

  AddContentProgress({required this.progress, this.filePath, this.completed = false});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'progress': progress, 'filePath': filePath, 'completed': completed};
  }

  factory AddContentProgress.fromMap(Map<String, dynamic> map) {
    return AddContentProgress(
      progress: map['progress'] != null ? map['progress'] as double : null,
      filePath: map['filePath'] != null ? map['filePath'] as String : null,
      completed: map['completed'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory AddContentProgress.fromJson(String source) =>
      AddContentProgress.fromMap(json.decode(source) as Map<String, dynamic>);
}
