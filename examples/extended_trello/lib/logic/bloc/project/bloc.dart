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
    // create project with one stage and one card
    _project = Project(title: 'Demo Project');
    final stage = Stage(title: 'POC');
    _project.addStage(stage);
    final task = Task(title: 'New Task', description: 'Some Description');
    final card = Badge(
      position: material.Offset(
        (_project.stages.length - 1) * COLUMN_WIDTH,
        stage.badges.length * DEFAULT_CARD_HEIGHT,
      ),
      task: task,
      inputId: _uuid.v1(),
      outputId: _uuid.v1(),
      key: _uuid.v1(),
    );
    stage.addCard(card);

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
      case CreateCard:
        _createCard(action as CreateCard);
        break;
      case DeleteCard:
        _deleteCard(action as DeleteCard);
        break;
      case UpdateCard:
        _updateCard(action as UpdateCard);
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
    // todo
  }

  void _updateStage(UpdateStage action) {
    // todo
  }

  void _createCard(CreateCard action) {
    // todo
  }

  void _deleteCard(DeleteCard action) {
    // todo
  }

  void _updateCard(UpdateCard action) {
    // todo
  }

  void _createRelation(CreateRelation action) {
    // todo
  }

  void _removeRelation(RemoveRelation action) {
    // todo
  }
}
