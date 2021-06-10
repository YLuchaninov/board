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

class CreateCard extends Action {
  final Stage stage;

  CreateCard(this.stage);
}

class DeleteCard extends Action {
  final Badge card;

  DeleteCard(this.card);
}

class UpdateCard extends Action {
  final Badge card;

  UpdateCard(this.card);
}

class CreateRelation extends Action {
  final Relation relation;

  CreateRelation(this.relation);
}

class RemoveRelation extends Action {
  final Relation relation;

  RemoveRelation(this.relation);
}
