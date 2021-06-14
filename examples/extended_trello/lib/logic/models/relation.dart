import 'package:flutter/material.dart';

class Relation {
  final String startId;
  final String endId;
  final String? comment;

  Relation({
    required this.startId,
    required this.endId,
    this.comment,
  });

  @override
  String toString() => 'Relation[$startId-$endId]';

  @override
  bool operator ==(Object other) =>
      other is Relation &&
      ((startId == other.startId && endId == other.endId) ||
          (startId == other.endId && endId == other.startId));

  @override
  int get hashCode => hashValues(startId, endId);
}
