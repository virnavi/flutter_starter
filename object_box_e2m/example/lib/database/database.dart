import 'package:example/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class Database {
  static Database? _instance;

  static Database get shared {
    if (_instance == null) {
      throw Exception('Database not Initialized');
    }
    return _instance!;
  }

  static Future<Database> initialize() async {
    if (_instance == null) {
      _instance = Database();
      await _instance!.init();
    }

    return _instance!;
  }

  late final Store store;

  Box<T> box<T>() => store.box<T>();

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    store = await openStore(directory: p.join(dir.path, "obx-e2m-example"));
  }
}
