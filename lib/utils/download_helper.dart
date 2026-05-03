import 'dart:async';
import 'dart:convert';

import 'package:universal_html/html.dart' as html;

class DownloadHelper {
  static void downloadXml(String content, String filename) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'application/xml');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

class ClipboardHelper {
  static Future<void> copyToClipboard(String text) async {
    await html.window.navigator.clipboard?.writeText(text);
  }
}

class FilePickerHelper {
  static Future<({String content, String name})?> pickXmlFile() {
    final completer = Completer<({String content, String name})?>();

    final input = html.FileUploadInputElement()
      ..accept = '.xml,text/xml,application/xml,text/plain'
      ..style.display = 'none';

    // Gunakan querySelector('body') — lebih aman dari document.body yang bisa null
    final body = html.document.querySelector('body');
    if (body == null) {
      completer.complete(null);
      return completer.future;
    }

    body.append(input);

    // Listener untuk file dipilih
    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        _cleanup(input, completer, null);
        return;
      }

      final file = files.first;
      final reader = html.FileReader();

      reader.onLoad.listen((_) {
        final result = reader.result as String?;
        _cleanup(
          input,
          completer,
          result != null ? (content: result, name: file.name) : null,
        );
      });

      reader.onError.listen((_) => _cleanup(input, completer, null));
      reader.readAsText(file);
    });

    // Deteksi cancel: pakai visibilitychange + mousedown lebih reliable dari onFocus
    // yang bisa fire saat app pertama load
    Timer? cancelTimer;

    void startCancelTimer() {
      cancelTimer?.cancel();
      cancelTimer = Timer(const Duration(milliseconds: 800), () {
        if (!completer.isCompleted) {
          _cleanup(input, completer, null);
        }
      });
    }

    // mousedown setelah file dialog tutup (user click di luar / cancel)
    html.document.onMouseDown.first.then((_) => startCancelTimer());

    // touchstart untuk mobile
    html.document.onTouchStart.first.then((_) => startCancelTimer());

    input.click();
    return completer.future;
  }

  static void _cleanup(
    html.FileUploadInputElement input,
    Completer<({String content, String name})?> completer,
    ({String content, String name})? result,
  ) {
    try {
      input.remove();
    } catch (_) {}
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }
}
