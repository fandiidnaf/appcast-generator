import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// File download helper powered by modern Wasm-ready package:web.
class WebDownloadHelper {
  WebDownloadHelper._();

  static void downloadString(
    String content,
    String filename, {
    String mimeType = 'application/xml',
  }) {
    final bytes = utf8.encode(content);
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: mimeType),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';

    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  }
}
