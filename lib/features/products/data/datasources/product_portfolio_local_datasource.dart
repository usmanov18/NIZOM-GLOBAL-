import 'dart:convert';
import 'package:hive/hive.dart';

import '../../domain/entities/product_portfolio.dart';

abstract class ProductPortfolioLocalDataSource {
  Future<List<ProductPortfolio>> getPortfolios();
  Future<void> savePortfolios(List<ProductPortfolio> portfolios);
  Future<PortfolioAssignment?> getAssignment(String userId, String role);
  Future<void> saveAssignment(PortfolioAssignment assignment);
  Future<void> saveAuditLog(PortfolioAuditLog log);
  Future<List<PortfolioAuditLog>> getAuditLogs({String? targetUserId});
}

class ProductPortfolioLocalDataSourceImpl
    implements ProductPortfolioLocalDataSource {
  static const _boxName = 'product_portfolios';

  @override
  Future<List<ProductPortfolio>> getPortfolios() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('portfolios');
    if (raw == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    return list.map(ProductPortfolio.fromJson).toList();
  }

  @override
  Future<void> savePortfolios(List<ProductPortfolio> portfolios) async {
    final box = await Hive.openBox(_boxName);
    await box.put(
        'portfolios', jsonEncode(portfolios.map((e) => e.toJson()).toList()));
  }

  @override
  Future<PortfolioAssignment?> getAssignment(String userId, String role) async {
    final box = await Hive.openBox(_boxName);
    final key = 'assignment_${role}_$userId';
    final raw = box.get(key);
    if (raw == null) return null;
    return PortfolioAssignment.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw)));
  }

  @override
  Future<void> saveAssignment(PortfolioAssignment assignment) async {
    final box = await Hive.openBox(_boxName);
    final key = 'assignment_${assignment.userRole}_${assignment.userId}';
    await box.put(key, jsonEncode(assignment.toJson()));
  }

  @override
  Future<void> saveAuditLog(PortfolioAuditLog log) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('audit_logs');
    final logs = raw == null
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(jsonDecode(raw));
    logs.add(log.toJson());
    await box.put('audit_logs', jsonEncode(logs));
  }

  @override
  Future<List<PortfolioAuditLog>> getAuditLogs({String? targetUserId}) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('audit_logs');
    if (raw == null) return [];
    final logs = List<Map<String, dynamic>>.from(jsonDecode(raw))
        .map(PortfolioAuditLog.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (targetUserId == null) return logs;
    return logs.where((log) => log.targetUserId == targetUserId).toList();
  }
}
