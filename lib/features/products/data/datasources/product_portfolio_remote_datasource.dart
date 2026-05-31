import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';

abstract class ProductPortfolioRemoteDataSource {
  Future<List<Map<String, dynamic>>> getPortfolios();
  Future<Map<String, dynamic>> getPortfolioById(String id);
  Future<Map<String, dynamic>> getAssignmentForUser(String userId);
  Future<void> saveAssignment(String userId, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getAuditLogs({String? targetUserId});
}

class ProductPortfolioRemoteDataSourceImpl
    implements ProductPortfolioRemoteDataSource {
  final Dio dio;

  ProductPortfolioRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Map<String, dynamic>>> getPortfolios() async {
    final response = await dio.get(ApiEndpoints.productPortfolios);
    return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
  }

  @override
  Future<Map<String, dynamic>> getPortfolioById(String id) async {
    final response = await dio.get(ApiEndpoints.productPortfolioById(id));
    return Map<String, dynamic>.from(response.data['data'] ?? response.data);
  }

  @override
  Future<Map<String, dynamic>> getAssignmentForUser(String userId) async {
    final response =
        await dio.get(ApiEndpoints.userPortfolioAssignment(userId));
    return Map<String, dynamic>.from(response.data['data'] ?? response.data);
  }

  @override
  Future<void> saveAssignment(String userId, Map<String, dynamic> data) async {
    await dio.put(ApiEndpoints.userPortfolioAssignment(userId), data: data);
  }

  @override
  Future<List<Map<String, dynamic>>> getAuditLogs(
      {String? targetUserId}) async {
    final response = await dio.get(
      targetUserId == null
          ? ApiEndpoints.portfolioAudit
          : ApiEndpoints.userPortfolioAudit(targetUserId),
    );
    return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
  }
}
