import 'package:isar/isar.dart';

class BaseNoSqlEntity {
  Id tempId = Isar.autoIncrement;
  DateTime updatedDateTime = DateTime.now();
}
