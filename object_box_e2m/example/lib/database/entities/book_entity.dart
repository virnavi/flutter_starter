import 'package:example/models/book_model.dart';
import 'package:object_box_e2m/object_box_e2m.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class BookEntity extends BaseNoSqlEntity {
  int id;
  String name;

  BookEntity({this.id = 0, required this.name});

  BookModel toModel() => BookModel(id: id, name: name);

  factory BookEntity.fromModel(BookModel model) =>
      BookEntity(id: model.id, name: model.name);
}
