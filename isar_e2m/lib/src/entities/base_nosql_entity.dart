import 'package:isar_community/isar.dart';

class BaseNoSqlEntity {
  Id tempId = Isar.autoIncrement;
  DateTime updatedDateTime = DateTime.now();
}
