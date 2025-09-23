import 'dart:async';

import 'package:common_sdk/src/models/models.dart';

abstract class ModelStream<Model> extends Stream<Optional<Model>> {
  bool get initialDataSent;
}
