import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class ShareUtils {
  /// Method to share text
  static Future<void> shareText(String text) async {
    try {
      await Share.share(text);
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing : $e');
      }
    }
  }
}
