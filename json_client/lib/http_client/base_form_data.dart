part of 'http_client.dart';

abstract class BaseFormData extends BaseJson {
  Future<FormData> toFormData();
  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
