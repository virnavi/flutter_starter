import 'package:common_sdk/common_sdk.dart';
import 'package:example/database/database.dart';
import 'package:example/database/entities/book_entity.dart';
import 'package:example/models/book_model.dart';
import 'package:example/objectbox.g.dart';
import 'package:object_box_e2m/object_box_e2m.dart';

class BookDao extends BaseNoSqlDaoImpl<BookModel, BookEntity, int> {
  @override
  Optional<BookEntity> convertToEntity(model) {
    if (model == null) {
      return Optional.empty();
    }
    return Optional.ofNullable(BookEntity.fromModel(model));
  }

  @override
  Optional<BookModel> convertToModel(BookEntity? entity) =>
      Optional.ofNullable(entity?.toModel());

  @override
  Box<BookEntity> get entityCollection => Database.shared.box<BookEntity>();

  @override
  Condition<BookEntity> idEqual(value) => BookEntity_.id.equals(value);

  @override
  idFromModel(model) => model.id;
}
