import 'package:file_picker/file_picker.dart';

Future<bool> pickDocument() async {
  final result = await FilePicker.platform.pickFiles();
  return result != null;
}
