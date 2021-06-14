import 'package:flutter/material.dart';
import 'index.dart';

class Project {
  final String title;
  final List<Stage> _stages = [];
  final Set<Relation> _relations = {};

  Project({required this.title});

  void addStage(Stage stage) => _stages.add(stage);

  bool removeStage(Stage stage) => _stages.remove(stage);

  List<Stage> get stages => List.unmodifiable(_stages);

  void addRelation(Relation relation) => _relations.add(relation);

  bool removeRelation(Relation relation) => _relations.remove(relation);

  void removeRelationWhere(bool Function(Relation) test) =>
      _relations.removeWhere(test);

  List<Relation> get relations => List.unmodifiable(_relations.toList());

  @override
  String toString() => 'Project[$title]';

  @override
  bool operator ==(Object other) =>
      other is Project && hashCode == other.hashCode;

  @override
  int get hashCode => hashValues(title, _stages.hashCode, _relations.hashCode);
}
