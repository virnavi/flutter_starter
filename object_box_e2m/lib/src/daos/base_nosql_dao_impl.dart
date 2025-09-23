import 'package:common_sdk/common_sdk.dart';
import 'package:objectbox/objectbox.dart';

import '../entities/base_nosql_entity.dart';
import 'base_nosql_dao.dart';

abstract class BaseNoSqlDaoImpl<Model, Entity extends BaseNoSqlEntity, IdType>
    implements BaseNoSqlDao<Model, IdType> {
  Box<Entity> get entityCollection;

  BaseNoSqlDaoImpl();

  @override
  Future<void> clear({String? correlationId}) async {
    await entityCollection.removeAllAsync();
  }

  @override
  Future<Optional<Model>> getById(IdType id, {String? correlationId}) async {
    final condition = idEqual(id);
    final query = entityCollection.query(condition).build();
    final data = await query.findFirstAsync();
    query.close();
    return convertToModel(data);
  }

  @override
  Future<ModelStream<Model>> getByIdWatcher(
    IdType id, {
    String? correlationId,
  }) async {
    final condition = idEqual(id);
    QueryBuilder<Entity> queryBuilder = entityCollection.query(condition);
    final dataListStream = queryBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
    return ModelObjectListStreamImpl<Model, Entity>(
      stream: dataListStream,
      convertToModel: convertToModel,
    );
  }

  @override
  Future<List<Model>> getAll({String? correlationId}) async {
    final entityList = entityCollection.getAll();
    final list = <Model>[];
    for (Entity entity in entityList) {
      list.add(convertToModel(entity).data);
    }
    return list;
  }

  @override
  Future<ModelStream<List<Model>>> getAllWatcher({
    String? correlationId,
  }) async {
    final queryBuilder = entityCollection.query();
    final dataListStream = queryBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
    return ModelStreamImpl<List<Model>, List<Entity>>(
      stream: dataListStream,
      convertToModel: convertToModelList,
    );
  }

  @override
  Future<List<Model>> getIdList(
    List<IdType> idList, {
    String? correlationId,
  }) async {
    final query = _buildQuery(idList).build();
    final entityList = await query.findAsync();
    final list = <Model>[];
    for (Entity entity in entityList) {
      list.add(convertToModel(entity).data);
    }
    query.close();
    return list;
  }

  @override
  Future<ModelStream<List<Model>>> getIdListWatcher(
    List<IdType> idList, {
    String? correlationId,
  }) async {
    final query = _buildQuery(idList, correlationId: correlationId);
    final dataListStream = query
        .watch(triggerImmediately: true)
        .map((query) => query.find());
    return ModelStreamImpl<List<Model>, List<Entity>>(
      stream: dataListStream,
      convertToModel: convertToModelList,
    );
  }

  QueryBuilder<Entity> _buildQuery(
    List<IdType> idList, {
    String? correlationId,
  }) {
    if (idList.isNotEmpty) {
      final conditions = <Condition<Entity>>[];
      for (IdType id in idList) {
        conditions.add(idEqual(id));
      }
      final combinedCondition = conditions.reduce((a, b) => a | b);

      return entityCollection.query(combinedCondition);
    }
    return entityCollection.query();
  }

  @override
  Future<void> upsert(Model model, {String? correlationId}) async {
    final entityOption = convertToEntity(model);
    final entity = entityOption.data;

    await entityCollection.putAsync(entity);
  }

  @override
  Future<void> upsertAll(List<Model> dataList, {String? correlationId}) async {
    List<Entity> entityList = [];

    for (var model in dataList) {
      final entity = convertToEntity(model).data;
      entityList.add(entity);
    }

    await entityCollection.putManyAsync(entityList);
  }

  @override
  Future<void> delete(IdType id, {String? correlationId}) async {
    final condition = idEqual(id);
    await entityCollection.query(condition).build().removeAsync();
  }

  @override
  Future<void> deleteAll(List<IdType> idList, {String? correlationId}) async {
    final queryBuilder = _buildQuery(idList);
    final query = queryBuilder.build();
    await query.removeAsync();
    query.close();
    return;
  }

  IdType idFromModel(Model model);

  Condition<Entity> idEqual(IdType value);

  Optional<Model> convertToModel(Entity? entity);

  Optional<Entity> convertToEntity(Model? model);

  Optional<List<Model>> convertToModelList(List<Entity>? entityList) {
    if (entityList == null) return Optional.empty<List<Model>>();
    final list = <Model>[];
    Optional<Model> dataOption = Optional.empty();
    for (Entity entity in entityList) {
      dataOption = convertToModel(entity);
      if (dataOption.hasData) {
        list.add(dataOption.data);
      }
    }
    return Optional.ofNullable(list);
  }
}
