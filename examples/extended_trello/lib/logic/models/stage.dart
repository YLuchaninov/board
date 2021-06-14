import 'package:flutter/material.dart';
import 'badge.dart';

class Stage {
  final String title;
  final List<Badge> _badges = [];

  Stage({
    required this.title,
  });

  void addBadge(Badge badge) => _badges.add(badge);

  bool removeBadge(Badge badge) => _badges.remove(badge);

  List<Badge> get badges => List.unmodifiable(_badges);

  @override
  String toString() => 'Stage[$title]';

  @override
  bool operator ==(Object other) =>
      other is Stage && hashCode == other.hashCode;

  @override
  int get hashCode => hashValues(title, _badges.hashCode);
}
