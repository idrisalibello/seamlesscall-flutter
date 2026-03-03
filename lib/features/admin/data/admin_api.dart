import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';

class AdminApi {
  
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> getProviderApplications({required String token}) async {
    try {
      final response = await _dio.get(
        '/admin/provider-applications',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'] as List<dynamic>;
    } on DioError catch (e) {
      throw Exception('Failed to fetch provider applications: ${e.message}');
    }
  }
}
