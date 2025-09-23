import 'base_nosql_entity.dart';
import '../constants/db_constants.dart';

class BaseNoSqlSingletonEntity extends BaseNoSqlEntity {
  @override
  int get tempId => DbConstants.singletonId;
  String value = '';
}
