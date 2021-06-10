import 'package:flutter/material.dart';
import 'badge.dart';

class Stage {
  final String title;
  final List<Badge> _badges = [];

  Stage({
    required this.title,
  });

  void addCard(Badge card) => _badges.add(card);

  bool removeCard(Badge card) => _badges.remove(card);

  List<Badge> get badges => List.unmodifiable(_badges);

  @override
  String toString() => 'Stage[$title]';

  @override
  bool operator ==(Object other) =>
      other is Stage && hashCode == other.hashCode;

  @override
  int get hashCode => hashValues(title, _badges);
}
