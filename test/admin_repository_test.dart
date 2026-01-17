// test/admin_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';
import 'package:seamlesscall/features/config/data/models/category_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AdminRepository', () {
    late AdminRepository adminRepository;

    setUp(() {
      adminRepository = AdminRepository();
    });

    test('getCategories() should fetch categories without throwing an error', () async {
      // This test does not mock the Dio client, so it will make a real HTTP request.
      // It's intended to be an integration test to verify the endpoint is working.
      // For this to pass, the backend must be running and accessible.

      // Set a dummy token to bypass the flutter_secure_storage dependency in tests.
      adminRepository.setTokenForTest('dummy-test-token');

      try {
        final List<Category> categories = await adminRepository.getCategories();
        // If we get here, the call was successful (no exception was thrown).
        // We can optionally check if the list is not null.
        expect(categories, isNotNull);
        print('Successfully fetched ${categories.length} categories.');
      } catch (e) {
        // If any exception is caught, fail the test.
        fail('getCategories() threw an exception: $e');
      }
    });
  });
}
