import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String login, String password);
  Future<bool> sendOTP(String phone);
  Future<Map<String, dynamic>> verifyOTP(String phone, String otp);
  Future<void> logout(String token);
  Future<bool> resetPassword(String phone);
  Future<bool> changePassword(
    String token,
    String oldPassword,
    String newPassword,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> login(String login, String password) async {
    final response = await dio.post(
      '/auth/login',
      data: {'username': login, 'password': password},
    );
    return response.data;
  }

  @override
  Future<bool> sendOTP(String phone) async {
    final response = await dio.post('/auth/send-otp', data: {'phone': phone});
    return response.statusCode == 200;
  }

  @override
  Future<Map<String, dynamic>> verifyOTP(String phone, String otp) async {
    final response = await dio.post(
      '/auth/verify-otp',
      data: {'phone': phone, 'otp': otp},
    );
    return response.data;
  }

  @override
  Future<void> logout(String token) async {
    await dio.post('/auth/logout');
  }

  @override
  Future<bool> resetPassword(String phone) async {
    final response = await dio.post(
      '/auth/reset-password',
      data: {'phone': phone},
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> changePassword(
    String token,
    String oldPassword,
    String newPassword,
  ) async {
    final response = await dio.post(
      '/auth/change-password',
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.statusCode == 200;
  }
}
