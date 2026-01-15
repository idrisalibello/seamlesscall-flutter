import 'package:dio/dio.dart';

class AdminApi {
  // Note: This uses the same singleton Dio instance as AuthApi.
  // This is an existing pattern in the app.
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.88.93.59/seamless_call/public/api/v1',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<List<dynamic>> getProviderApplications({required String token}) async {
    try {
      final response = await _dio.get(
        '/admin/provider-applications',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.data['data'] as List<dynamic>;
    } on DioError catch (e) {
      throw Exception('Failed to fetch provider applications: ${e.message}');
    }
  }
}
