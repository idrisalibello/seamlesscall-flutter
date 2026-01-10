import 'dart:async';
import 'dart:html' as html;

Future<bool> pickDocument() async {
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = '.pdf,.jpg,.jpeg,.png';

  final completer = Completer<bool>();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    completer.complete(files != null && files.isNotEmpty);
  });

  uploadInput.click();
  return completer.future;
}
