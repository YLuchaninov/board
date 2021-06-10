import 'package:flutter/material.dart';

enum TaskStatus { fresh, completed, started }

class Task {
  String title;
  String description;
  TaskStatus status;
  final DateTime created;

  Task({
    required this.title,
    required this.description,
    this.status: TaskStatus.fresh,
    created,
  }) : this.created = created ?? DateTime.now();

  @override
  String toString() => 'Task[ $title : $description : $status]';

  @override
  bool operator ==(Object other) => other is Task &&
      title == other.title &&
      description == other.description &&
      status == other.status;

  @override
  int get hashCode => hashValues(title, description);

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'created': created.toString(),
        'status': status.index,
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
    title: json['title'],
    description: json['description'],
    created: DateTime.parse(json['created']),
    status: TaskStatus.values[json['status']],
  );
}
