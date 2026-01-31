Future<void> downloadTextFile({
  required String filename,
  required String content,
  required String mimeType,
}) {
  throw UnsupportedError('File export is only supported on Web for now.');
}

Future<void> openPrintWindow({
  required String title,
  required String htmlBody,
}) {
  throw UnsupportedError('PDF/Print export is only supported on Web for now.');
}
