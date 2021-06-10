import 'dart:async';

import '../models/index.dart';
import 'project/bloc.dart';
import 'actions.dart';

class BLoC {
  ProjectBLoC _projectBLoC = ProjectBLoC();

  Stream<Project> get project => _projectBLoC.project;

  Sink<Action> get action => _projectBLoC.action;

  dispose() {
    _projectBLoC.dispose();
  }
}
