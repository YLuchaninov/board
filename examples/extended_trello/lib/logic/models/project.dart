import 'package:flutter/material.dart';
import 'index.dart';

class Project {
  final String title;
  final List<Stage> _stages = [];
  final List<Relation> _relations = [];

  Project({required this.title});

  void addStage(Stage stage) => _stages.add(stage);

  List<Stage> get stages => List.unmodifiable(_stages);

  void addRelation(Relation relation) => _relations.add(relation);

  List<Relation> get relations => List.unmodifiable(_relations);


  @override
  String toString() => 'Project[$title]';

  @override
  bool operator ==(Object other) =>
      other is Project && hashCode == other.hashCode;

  @override
  int get hashCode => hashValues(title, _stages, _relations);

}
