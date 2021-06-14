import 'package:flutter/material.dart' as material;
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

import '../../index.dart';
import '../../../ui/constants/index.dart';

class ProjectBLoC {
  final _actionController = PublishSubject<Action>();

  Sink<Action> get action => _actionController.sink;

  final _projectSubject = BehaviorSubject<Project>();

  Stream<Project> get project => _projectSubject.stream;

  ProjectBLoC() {
    _actionController.stream.listen(_dispatcher);
    _init();
  }

  final _uuid = Uuid();
  late Project _project;

  _init() async {
    // create project with one stage and one badge
    _project = Project(title: 'Demo Project');
    final stage = Stage(title: 'POC');
    _project.addStage(stage);
    final task = Task(title: 'New Task', description: 'Some Description');
    final badge = Badge(
      position: material.Offset(
        (_project.stages.length - 1) * COLUMN_WIDTH,
        stage.badges.length * DEFAULT_CARD_HEIGHT,
      ),
      task: task,
      inputId: _uuid.v1(),
      outputId: _uuid.v1(),
      key: _uuid.v1(),
    );
    stage.addBadge(badge);

    _projectSubject.add(_project);
  }

  _dispatcher(Action action) {
    switch (action.runtimeType) {
      case CreateStage:
        _createStage(action as CreateStage);
        break;
      case DeleteStage:
        _deleteStage(action as DeleteStage);
        break;
      case UpdateStage:
        _updateStage(action as UpdateStage);
        break;
      case CreateBadge:
        _createBadge(action as CreateBadge);
        break;
      case DeleteBadge:
        _deleteBadge(action as DeleteBadge);
        break;
      case UpdateBadge:
        _updateBadge(action as UpdateBadge);
        break;
      case CreateRelation:
        _createRelation(action as CreateRelation);
        break;
      case RemoveRelation:
        _removeRelation(action as RemoveRelation);
        break;
    }
  }

  dispose() {
    _actionController.close();
    _projectSubject.close();
  }

  void _createStage(CreateStage action) {
    final stage = Stage(title: 'New Stage');
    _project.addStage(stage);
    _projectSubject.add(_project);
  }

  void _deleteStage(DeleteStage action) {
    action.stage.badges.forEach((badge) => _removeBadgeRelation(badge));
    _project.removeStage(action.stage);
    _projectSubject.add(_project);
  }

  void _updateStage(UpdateStage action) {
    // todo
  }

  void _createBadge(CreateBadge action) {
    final stages = _project.stages;
    if (stages.length == 0) return;

    final task = Task(title: 'New Task', description: 'Some Description');
    if (action.offset != null) {
      final stage = _getStageByOffset(action.offset!);
      final badge = Badge(
        position: action.offset ?? material.Offset.zero,
        task: task,
        inputId: _uuid.v1(),
        outputId: _uuid.v1(),
        key: _uuid.v1(),
      );
      stage.addBadge(badge);
    } else if (action.stage != null) {
      final badge = Badge(
        position: material.Offset(
          (stages.indexOf(action.stage!)) * COLUMN_WIDTH,
          action.stage!.badges.length * DEFAULT_CARD_HEIGHT, // todo
        ),
        task: task,
        inputId: _uuid.v1(),
        outputId: _uuid.v1(),
        key: _uuid.v1(),
      );
      action.stage!.addBadge(badge);
    }
    _projectSubject.add(_project);
  }

  void _deleteBadge(DeleteBadge action) {
    _project.stages.forEach((stage) => stage.removeBadge(action.badge));
    _removeBadgeRelation(action.badge);
    _projectSubject.add(_project);
  }

  void _updateBadge(UpdateBadge action) {
    final badge = action.badge;
    _project.stages.forEach((stage) => stage.removeBadge(badge));

    final stage = _getStageByOffset(badge.position);
    stage.addBadge(badge);
    _projectSubject.add(_project);
  }

  void _createRelation(CreateRelation action) {
    if (action.relation.startId == action.relation.endId) return;
    bool theSameBadge = false;
    _project.stages.forEach((stage) {
      stage.badges.forEach((badge) {
        theSameBadge = ((badge.outputId == action.relation.startId) ||
                (badge.outputId == action.relation.endId)) &&
            ((badge.inputId == action.relation.startId) ||
                (badge.inputId == action.relation.endId));
      });
    });
    if(theSameBadge) return;

    _project.addRelation(action.relation);
    _projectSubject.add(_project);
  }

  void _removeRelation(RemoveRelation action) {
    _project.removeRelation(action.relation);
    _projectSubject.add(_project);
  }

  Stage _getStageByOffset(material.Offset offset) {
    final stages = _project.stages;
    int index = (offset.dx / COLUMN_WIDTH).ceil();
    if (index < 0) index = 0;
    if (index > stages.length - 1) index = stages.length - 1;

    return stages[index];
  }

  void _removeBadgeRelation(Badge badge) {
    _project.removeRelationWhere((relation) =>
        (relation.startId == badge.inputId) ||
        (relation.startId == badge.outputId) ||
        (relation.endId == badge.inputId) ||
        (relation.endId == badge.outputId));
  }
}
