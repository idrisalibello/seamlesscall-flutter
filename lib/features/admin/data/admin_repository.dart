import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/config/data/models/category_model.dart'; // Added
import 'package:seamlesscall/features/config/data/models/service_model.dart';   // Added

class AdminRepository {
  final DioClient _dioClient = DioClient();

  // Add this method to allow setting a token for testing
  void setTokenForTest(String token) {
    _dioClient.setTokenForTest(token);
  }

  Future<List<Map<String, dynamic>>> getProviderApplications() async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/admin/provider-applications', // Updated path
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
        '/api/v1/admin/provider-applications/status',
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
    }
    catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> createAdminUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/admin/users',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          // Role is fixed to 'Admin' on the backend
        },
      );

      if (response.statusCode == 201) { // 201 Created
        print('Admin user created successfully. Response: ${response.data}');
      } else {
        throw Exception('Failed to create admin user. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        print('Error response status: ${e.response?.statusCode}');
        // Attempt to extract a more user-friendly error message from the backend
        throw Exception('Failed to create admin user: ${e.response?.data['messages'] ?? e.message}');
      }
      else {
        print('Error sending request: ${e.message}');
        throw Exception('Error sending request: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- Category Management ---

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/categories');
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((e) => Category.fromMap(e))
            .toList();
      } else {
        throw Exception(
            'Failed to load categories. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('The requested categories were not found (404). Please check the API endpoint.');
      }
      throw Exception(
          'Failed to load categories: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Category> getCategoryDetails(int categoryId) async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/categories/$categoryId');
      if (response.statusCode == 200) {
        try {
          return Category.fromMap(response.data['data']);
        } catch (e) {
          print('Error parsing category details. Raw response: ${response.data}');
          throw Exception('Failed to parse category details: $e');
        }
      } else {
        throw Exception(
            'Failed to load category details. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load category details: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> createCategory({
    required String name,
    String? description,
    required String status,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/admin/categories',
        data: {
          'name': name,
          'description': description,
          'status': status,
        },
      );

      if (response.statusCode == 201) {
        print('Category created successfully. Response: ${response.data}');
      } else {
        throw Exception(
            'Failed to create category. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to create category: ${e.response?.data['messages'] ?? e.message}');
    }
    catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> updateCategory(
    int categoryId, {
    required String name,
    String? description,
    required String status,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '/api/v1/admin/categories/$categoryId',
        data: {
          'name': name,
          'description': description,
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        print('Category updated successfully. Response: ${response.data}');
      } else {
        throw Exception(
            'Failed to update category. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to update category: ${e.response?.data['messages'] ?? e.message}');
    }
    catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- Service Management ---

  Future<List<Service>> getServicesByCategory(int categoryId) async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/categories/$categoryId/services');
      if (response.statusCode == 200) {
        try {
          final dynamic rawData = response.data['data'];
          List<Map<String, dynamic>> normalizedList;

          if (rawData is List) {
            normalizedList = List<Map<String, dynamic>>.from(rawData);
          } else if (rawData is Map) {
            normalizedList = [Map<String, dynamic>.from(rawData)];
          } else {
            normalizedList = [];
          }

          final List<Service> services = [];
          for (var serviceMap in normalizedList) {
            try {
              services.add(Service.fromMap(serviceMap));
            } catch (e) {
              print('--- FAILED TO PARSE SERVICE MAP ---');
              print('--- Raw Service Map: $serviceMap');
              print('--- Parsing Error: $e');
              print('------------------------------------');
            }
          }
          return services;

        } catch (e) {
          print('Error during normalization. Raw response: ${response.data}');
          throw Exception('Failed during normalization: $e');
        }
      } else {
        throw Exception(
            'Failed to load services. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load services: ${e.response?.data['messages'] ?? e.message}');
    }
    catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> createService(
    int categoryId, {
    required String name,
    String? description,
    required String status,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/admin/categories/$categoryId/services',
        data: {
          'name': name,
          'description': description,
          'status': status,
        },
      );

      if (response.statusCode == 201) {
        print('Service created successfully. Response: ${response.data}');
      } else {
        throw Exception(
            'Failed to create service. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to create service: ${e.response?.data['messages'] ?? e.message}');
    }
    catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> updateService(
    int serviceId, {
    required String name,
    String? description,
    required String status,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '/api/v1/admin/services/$serviceId',
        data: {
          'name': name,
          'description': description,
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        print('Service updated successfully. Response: ${response.data}');
      } else {
        throw Exception(
            'Failed to update service. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to update service: ${e.response?.data['messages'] ?? e.message}');
    }
    catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
