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
      other is Relation && hashCode == other.hashCode;

  @override
  int get hashCode => hashValues(startId, endId);
}
