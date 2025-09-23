import 'package:objectbox/objectbox.dart';

class BaseNoSqlEntity {
  @Id()
  int tempId = 0;
  DateTime updatedDateTime = DateTime.now();
}
