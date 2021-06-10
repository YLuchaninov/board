import 'package:flutter/material.dart';
import 'task.dart';

class Badge {
  Offset position;
  Task task;
  final String inputId;
  final String outputId;
  final String key;

  Badge({
    required this.position,
    required this.task,
    required this.inputId,
    required this.outputId,
    required this.key,
  });

  @override
  String toString() => 'Card[ $task : $position]';

  @override
  bool operator ==(Object other) => other is Badge &&
      task == other.task &&
      position == other.position;

  @override
  int get hashCode => hashValues(task, position);
}
