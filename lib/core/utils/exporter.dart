import '../utils/exporter_stub.dart'
    if (dart.library.html) 'exporter_web.dart'
    as impl;

Future<void> downloadTextFile({
  required String filename,
  required String content,
  required String mimeType,
}) {
  return impl.downloadTextFile(
    filename: filename,
    content: content,
    mimeType: mimeType,
  );
}

Future<void> openPrintWindow({
  required String title,
  required String htmlBody,
}) {
  return impl.openPrintWindow(title: title, htmlBody: htmlBody);
}
