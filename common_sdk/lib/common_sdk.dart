library common_sdk;

import 'package:common_sdk/src/logger/logger.dart';

export 'src/models/models.dart';
export 'src/utils/utils.dart';
export 'src/wrappers/wrappers.dart';
export 'src/streams/streams.dart';
export 'src/logger/logger.dart';

class CommonSdk {
  static CommonSdk? _instance;

  static CommonSdk get shared {
    if (_instance == null) {
      throw Exception('CommonSdk Sdk not initialized');
    }
    return _instance!;
  }

  static CommonSdk initialize({required bool enableLogging}) {
    if (_instance != null) {
      throw Exception('CommonSdk Sdk  already initialized');
    }
    _instance = CommonSdk._(enableLogging: enableLogging);
    return _instance!;
  }

  CommonSdk._({required bool enableLogging}) {
    Logger.initialize(enableLogging: enableLogging);
  }
}
