import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';

class AdminRepository {
  final DioClient _dioClient = DioClient();

  Future<List<Map<String, dynamic>>> getProviderApplications() async {
    try {
      final response = await _dioClient.dio.get(
        '/admin/provider-applications', // This path will be appended to baseUrl
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('Failed to load provider applications. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        print('Error response status: ${e.response?.statusCode}');
        throw Exception('Failed to load provider applications: ${e.response?.data['messages'] ?? e.message}');
      } else {
        print('Error sending request: ${e.message}');
        throw Exception('Error sending request: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> approveOrRejectProvider(int userId, String action) async {
    try {
      final response = await _dioClient.dio.post(
        '/admin/provider-applications/status',
        data: {
          'user_id': userId,
          'action': action,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Provider application $action. Response: ${response.data}');
      } else {
        print('Failed to $action provider application. Status code: ${response.statusCode}');
        throw Exception('Failed to $action provider application. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        print('Error response status: ${e.response?.statusCode}');
        throw Exception('Failed to $action provider application: ${e.response?.data['messages'] ?? e.message}');
      } else {
        print('Error sending request: ${e.message}');
        throw Exception('Error sending request: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}