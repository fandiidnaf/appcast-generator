import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// File picker helper using package:web.
class WebPickerHelper {
  WebPickerHelper._();

  static Future<({String content, String name})?> pickTextFile({
    String accept = '.xml,text/xml,application/xml,text/plain',
  }) {
    final completer = Completer<({String content, String name})?>();
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = accept
      ..style.display = 'none';

    final body = web.document.body;
    if (body == null) {
      completer.complete(null);
      return completer.future;
    }

    body.append(input);

    input.onchange = (web.Event event) {
      final files = input.files;
      if (files == null || files.length == 0) {
        input.remove();
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      final file = files.item(0)!;
      final reader = web.FileReader();

      reader.onload = (web.Event _) {
        final result = reader.result;
        final text = (result as JSString?)?.toDart ?? '';
        input.remove();
        if (!completer.isCompleted) {
          completer.complete((content: text, name: file.name));
        }
      }.toJS;

      reader.onerror = (web.Event _) {
        input.remove();
        if (!completer.isCompleted) completer.complete(null);
      }.toJS;

      reader.readAsText(file);
    }.toJS;

    input.click();
    return completer.future;
  }
}
