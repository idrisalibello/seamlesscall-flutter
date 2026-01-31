import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<void> downloadTextFile({
  required String filename,
  required String content,
  required String mimeType,
}) async {
  final bytes = utf8.encode(content);

  // Blob expects JSAny parts
  final blob = web.Blob(
    [bytes.toJS].toJS, // List<JSAny>
    web.BlobPropertyBag(type: mimeType.toJS.toString()),
  );

  final url = web.URL.createObjectURL(blob);

  final a = web.HTMLAnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';

  web.document.body?.append(a);
  a.click();
  a.remove();

  web.URL.revokeObjectURL(url);
}

Future<void> openPrintWindow({
  required String title,
  required String htmlBody,
}) async {
  final w = web.window.open('', '_blank');
  if (w == null) return;

  final doc = w.document;
  doc.open();

  final page =
      '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>${_escapeHtml(title)}</title>
  <style>
    body { font-family: Arial, sans-serif; padding: 16px; }
    h2 { margin: 0 0 12px; }
    table { width: 100%; border-collapse: collapse; }
    th, td { border: 1px solid #ddd; padding: 8px; font-size: 12px; }
    th { background: #f5f5f5; text-align: left; }
    .meta { color: #666; font-size: 12px; margin-bottom: 10px; }
  </style>
</head>
<body>
  $htmlBody
</body>
</html>
''';

  // write expects JSAny
  doc.write(page.toJS);

  doc.close();

  w.focus();
  w.print();
}

String _escapeHtml(String s) {
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
