import 'package:common_sdk/common_sdk.dart';

import '../streams/model_stream.dart';

abstract class BaseNoSqlDao<Model, IdType> {
  Future<Optional<Model>> getById(
    IdType id, {
    String? correlationId,
  });

  Future<ModelStream<Model>> getByIdWatcher(
    IdType id, {
    String? correlationId,
  });

  Future<List<Model>> getAll({
    String? correlationId,
  });

  Future<ModelStream<List<Model>>> getAllWatcher({
    String? correlationId,
  });

  Future<List<Model>> getIdList(
    List<IdType> idList, {
    String? correlationId,
  });

  Future<ModelStream<List<Model>>> getIdListWatcher(
    List<IdType> idList, {
    String? correlationId,
  });

  Future<void> upsert(
    Model data, {
    String? correlationId,
  });

  Future<void> upsertAll(
    List<Model> dataList, {
    String? correlationId,
  });

  Future<void> delete(
    IdType id, {
    String? correlationId,
  });

  Future<void> deleteAll(
    List<IdType> idList, {
    String? correlationId,
  });
  Future<void> clear({
    String? correlationId,
  });
}
