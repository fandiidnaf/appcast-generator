import 'package:flutter/services.dart';
import '../src/core/utils/web_download_helper.dart';
import '../src/core/utils/web_picker_helper.dart';

class DownloadHelper {
  static void downloadXml(String content, String filename) {
    WebDownloadHelper.downloadString(content, filename);
  }
}

class ClipboardHelper {
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}

class FilePickerHelper {
  static Future<({String content, String name})?> pickXmlFile() {
    return WebPickerHelper.pickTextFile();
  }
}
