import 'package:flutter/material.dart' as material;
import '../actions.dart';
import '../../index.dart';

class CreateStage extends Action {}

class DeleteStage extends Action {
  final Stage stage;

  DeleteStage(this.stage);
}

class UpdateStage extends Action {
  final String title;
  final Stage stage;

  UpdateStage({
    required this.title,
    required this.stage,
  });
}

class CreateBadge extends Action {
  final Stage? stage;
  final material.Offset? offset;

  CreateBadge({
    required this.stage,
    required this.offset,
  });
}

class DeleteBadge extends Action {
  final Badge badge;

  DeleteBadge(this.badge);
}

class UpdateBadge extends Action {
  final Badge badge;

  UpdateBadge(this.badge);
}

class CreateRelation extends Action {
  final Relation relation;

  CreateRelation(this.relation);
}

class RemoveRelation extends Action {
  final Relation relation;

  RemoveRelation(this.relation);
}
