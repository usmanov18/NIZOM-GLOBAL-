import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/entities/admin_extended_entities.dart';
import '../../domain/usecases/admin_usecases.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';
import '../datasources/admin_local_datasource.dart';

// ============================================================
// ADMIN REPOSITORY IMPLEMENTATION - To'liq
// ============================================================

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final AdminLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Map<String, List<DiscountRule>> _agentDiscountRules = {};
  final List<SyncLogEntry> _syncLogs = [];

  AdminRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // ============ DASHBOARD ============

  @override
  Future<Either<Failure, AdminDashboard>> getDashboard() async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getDashboard();
        await localDataSource.cacheDashboard(data);
        return Right(_parseDashboard(data));
      } else {
        final cached = await localDataSource.getCachedDashboard();
        if (cached != null) return Right(_parseDashboard(cached));
        return const Left(
            CacheFailure(message: 'Offline ma\'lumotlar topilmadi'));
      }
    } catch (e) {
      try {
        final cached = await localDataSource.getCachedDashboard();
        if (cached != null) return Right(_parseDashboard(cached));
      } catch (_) {}
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  AdminDashboard _parseDashboard(Map<String, dynamic> data) {
    return AdminDashboard(
      totalAgents: data['total_agents'] ?? 0,
      activeAgents: data['active_agents'] ?? 0,
      totalSupervisors: data['total_supervisors'] ?? 0,
      totalCustomers: data['total_customers'] ?? 0,
      activeCustomers: data['active_customers'] ?? 0,
      todayOrders: data['today_orders'] ?? 0,
      todaySales: (data['today_sales'] ?? 0).toDouble(),
      todayVisits: data['today_visits'] ?? 0,
      todayCollections: (data['today_collections'] ?? 0).toDouble(),
      weeklySales: (data['weekly_sales'] ?? 0).toDouble(),
      weeklyOrders: data['weekly_orders'] ?? 0,
      weeklyCollections: (data['weekly_collections'] ?? 0).toDouble(),
      monthlySales: (data['monthly_sales'] ?? 0).toDouble(),
      monthlyTarget: (data['monthly_target'] ?? 0).toDouble(),
      monthlyProgress: (data['monthly_progress'] ?? 0).toDouble(),
      is1CConnected: data['is_1c_connected'] ?? false,
      isSAPConnected: data['is_sap_connected'] ?? false,
      lastSyncTime: data['last_sync_time'] != null
          ? DateTime.parse(data['last_sync_time'])
          : null,
      pendingSyncItems: data['pending_sync_items'] ?? 0,
      overdueTasks: data['overdue_tasks'] ?? 0,
      overduePayments: data['overdue_payments'] ?? 0,
      blockedAgents: data['blocked_agents'] ?? 0,
    );
  }

  // ============ SYSTEM SETTINGS ============

  @override
  Future<Either<Failure, SystemSettings>> getSystemSettings() async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getSystemSettings();
        await localDataSource.cacheSettings(data);
        return Right(_parseSettings(data));
      } else {
        final cached = await localDataSource.getCachedSettings();
        if (cached != null) return Right(_parseSettings(cached));
        return const Left(CacheFailure(message: 'Sozlamalar topilmadi'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  SystemSettings _parseSettings(Map<String, dynamic> data) {
    return SystemSettings(
      id: data['id'] ?? '',
      companyName: data['company_name'] ?? '',
      companyCode: data['company_code'] ?? '',
      currency: data['currency'] ?? 'UZS',
      timezone: data['timezone'] ?? 'Asia/Tashkent',
      language: data['language'] ?? 'uz',
      is1CEnabled: data['is_1c_enabled'] ?? true,
      isSAPEnabled: data['is_sap_enabled'] ?? true,
      oneCBaseUrl: data['one_c_base_url'],
      sapBaseUrl: data['sap_base_url'],
      syncIntervalMinutes: data['sync_interval_minutes'] ?? 30,
      autoSyncEnabled: data['auto_sync_enabled'] ?? true,
      pushNotificationsEnabled: data['push_notifications'] ?? true,
      smsNotificationsEnabled: data['sms_notifications'] ?? false,
      emailNotificationsEnabled: data['email_notifications'] ?? false,
      gpsTrackingEnabled: data['gps_tracking'] ?? true,
      gpsIntervalSeconds: data['gps_interval'] ?? 30,
      requireGPSForCheckIn: data['require_gps_checkin'] ?? true,
      sessionTimeoutMinutes: data['session_timeout'] ?? 480,
      requireBiometric: data['require_biometric'] ?? false,
      maxLoginAttempts: data['max_login_attempts'] ?? 5,
      passwordMinLength: data['password_min_length'] ?? 8,
    );
  }

  @override
  Future<Either<Failure, SystemSettings>> updateSystemSettings(
      SystemSettings settings) async {
    try {
      final data = await remoteDataSource.updateSystemSettings({
        'company_name': settings.companyName,
        'currency': settings.currency,
        'timezone': settings.timezone,
        'language': settings.language,
        'is_1c_enabled': settings.is1CEnabled,
        'is_sap_enabled': settings.isSAPEnabled,
        'sync_interval_minutes': settings.syncIntervalMinutes,
        'gps_tracking': settings.gpsTrackingEnabled,
        'session_timeout': settings.sessionTimeoutMinutes,
      });
      await localDataSource.cacheSettings(data);
      return Right(_parseSettings(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> testConnection(String system) async {
    try {
      final result = await remoteDataSource.testConnection(system);
      return Right(result);
    } catch (e) {
      return const Right(false);
    }
  }

  // ============ AGENTS ============

  @override
  Future<Either<Failure, List<AdminAgent>>> getAllAgents(
      {String? status, String? search}) async {
    try {
      if (await networkInfo.isConnected) {
        final data =
            await remoteDataSource.getAllAgents(status: status, search: search);
        await localDataSource.cacheAgents(data);
        return Right(data.map((d) => _parseAgent(d)).toList());
      } else {
        final cached = await localDataSource.getCachedAgents(
            status: status, search: search);
        return Right(cached.map((d) => _parseAgent(d)).toList());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  AdminAgent _parseAgent(Map<String, dynamic> d) {
    return AdminAgent(
      id: d['id'] ?? '',
      code: d['code'] ?? '',
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
      regionId: d['region_id'] ?? '',
      regionName: d['region_name'] ?? '',
      supervisorId: d['supervisor_id'] ?? '',
      supervisorName: d['supervisor_name'] ?? '',
      warehouseId: d['warehouse_id'] ?? '',
      warehouseName: d['warehouse_name'] ?? '',
      status: d['status'] ?? 'active',
      blockReason: d['block_reason'],
      createdAt:
          DateTime.parse(d['created_at'] ?? DateTime.now().toIso8601String()),
      totalOrders: d['total_orders'] ?? 0,
      totalSales: (d['total_sales'] ?? 0).toDouble(),
      totalCustomers: d['total_customers'] ?? 0,
      totalVisits: d['total_visits'] ?? 0,
      rating: (d['rating'] ?? 0).toDouble(),
    );
  }

  @override
  Future<Either<Failure, AdminAgent>> getAgentById(String agentId) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getAgentById(agentId);
        await localDataSource.saveAgent(data);
        return Right(_parseAgent(data));
      } else {
        final cached = await localDataSource.getAgent(agentId);
        if (cached != null) return Right(_parseAgent(cached));
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AdminAgent>> createAgent(
      CreateAgentParams params) async {
    try {
      final data = await remoteDataSource.createAgent({
        'name': params.name,
        'code': params.code,
        'phone': params.phone,
        'email': params.email,
        'region_id': params.regionId,
        'supervisor_id': params.supervisorId,
        'warehouse_id': params.warehouseId,
      });
      await localDataSource.saveAgent(data);
      return Right(_parseAgent(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AdminAgent>> updateAgent(
      String agentId, UpdateAgentParams params) async {
    try {
      final data = await remoteDataSource.updateAgent(agentId, {
        if (params.name != null) 'name': params.name,
        if (params.phone != null) 'phone': params.phone,
        if (params.email != null) 'email': params.email,
        if (params.regionId != null) 'region_id': params.regionId,
      });
      await localDataSource.saveAgent(data);
      return Right(_parseAgent(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> blockAgent(
      String agentId, String reason) async {
    try {
      final result = await remoteDataSource.blockAgent(agentId, reason);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> unblockAgent(String agentId) async {
    try {
      final result = await remoteDataSource.unblockAgent(agentId);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> resetAgentPassword(String agentId) async {
    try {
      final result = await remoteDataSource.resetAgentPassword(agentId);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> assignAgentToSupervisor(
      String agentId, String supervisorId) async {
    try {
      await remoteDataSource
          .updateAgent(agentId, {'supervisor_id': supervisorId});
      return const Right(true);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ RESTRICTIONS ============

  @override
  Future<Either<Failure, List<AgentRestrictions>>> getAllRestrictions() async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getAllRestrictions();
        await localDataSource.cacheRestrictions(data);
        return Right(data.map((d) => _parseRestriction(d)).toList());
      } else {
        final cached = await localDataSource.getCachedRestrictions();
        return Right(cached.map((d) => _parseRestriction(d)).toList());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  AgentRestrictions _parseRestriction(Map<String, dynamic> d) {
    return AgentRestrictions(
      id: d['id'] ?? '',
      agentId: d['agent_id'] ?? '',
      agentName: d['agent_name'] ?? '',
      workStartTime: d['work_start_time'] ?? '08:00',
      workEndTime: d['work_end_time'] ?? '18:00',
      workDays: List<String>.from(d['work_days'] ?? []),
      canWorkOnWeekends: d['can_work_weekends'] ?? false,
      maxWorkHoursPerDay: d['max_work_hours_day'] ?? 8,
      maxWorkHoursPerWeek: d['max_work_hours_week'] ?? 48,
      orderStartTime: d['order_start_time'] ?? '08:00',
      orderEndTime: d['order_end_time'] ?? '17:00',
      canOrderOutsideWorkHours: d['can_order_outside'] ?? false,
      maxOrdersPerDay: d['max_orders_day'] ?? 20,
      maxOrdersPerWeek: d['max_orders_week'] ?? 100,
      maxSingleOrderAmount: (d['max_order_amount'] ?? 50000000).toDouble(),
      maxDailyOrderAmount: (d['max_daily_amount'] ?? 200000000).toDouble(),
      maxWeeklyOrderAmount: (d['max_weekly_amount'] ?? 1000000000).toDouble(),
      maxDiscountPercent: (d['max_discount_percent'] ?? 10).toDouble(),
      maxDiscountAmount: (d['max_discount_amount'] ?? 5000000).toDouble(),
      requireManagerApprovalAbove: d['require_approval'] ?? true,
      approvalThresholdAmount: (d['approval_threshold'] ?? 30000000).toDouble(),
      maxCashCollection: (d['max_cash_collection'] ?? 100000000).toDouble(),
      maxSinglePayment: (d['max_single_payment'] ?? 50000000).toDouble(),
      requireReceiptPhoto: d['require_receipt_photo'] ?? true,
      requireSignature: d['require_signature'] ?? true,
      allowedPaymentMethods: List<String>.from(
          d['payment_methods'] ?? ['cash', 'card', 'transfer']),
      maxVisitsPerDay: d['max_visits_day'] ?? 15,
      minVisitDurationMinutes: d['min_visit_duration'] ?? 15,
      maxTravelDistanceKm: (d['max_travel_distance'] ?? 50).toDouble(),
      requireCheckInPhoto: d['require_checkin_photo'] ?? true,
      requireCheckOutPhoto: d['require_checkout_photo'] ?? false,
      checkInRadiusMeters: (d['checkin_radius'] ?? 100).toDouble(),
      discountRules: [],
      effectiveFrom: DateTime.parse(
          d['effective_from'] ?? DateTime.now().toIso8601String()),
      isActive: d['is_active'] ?? true,
      createdBy: d['created_by'] ?? '',
      createdAt:
          DateTime.parse(d['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  Future<Either<Failure, AgentRestrictions>> getAgentRestrictions(
      String agentId) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getAgentRestrictions(agentId);
        await localDataSource.saveRestriction(data);
        return Right(_parseRestriction(data));
      } else {
        final cached = await localDataSource.getRestriction(agentId);
        if (cached != null) return Right(_parseRestriction(cached));
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AgentRestrictions>> updateRestrictions(
      AgentRestrictions restrictions) async {
    try {
      await remoteDataSource.updateRestrictions({
        'agent_id': restrictions.agentId,
        'work_start_time': restrictions.workStartTime,
        'work_end_time': restrictions.workEndTime,
        'work_days': restrictions.workDays,
        'max_orders_day': restrictions.maxOrdersPerDay,
        'max_order_amount': restrictions.maxSingleOrderAmount,
        'max_discount_percent': restrictions.maxDiscountPercent,
      });
      return Right(restrictions);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AgentRestrictions>> createRestrictions(
      AgentRestrictions restrictions) async {
    return updateRestrictions(restrictions);
  }

  @override
  Future<Either<Failure, bool>> applyRestrictionsToAll(
      AgentRestrictions restrictions) async {
    try {
      await remoteDataSource.updateRestrictions({'apply_to': 'all'});
      return const Right(true);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> applyRestrictionsToRegion(
      String regionId, AgentRestrictions restrictions) async {
    try {
      await remoteDataSource
          .updateRestrictions({'apply_to': 'region', 'region_id': regionId});
      return const Right(true);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ DISCOUNT POLICY ============

  @override
  Future<Either<Failure, GlobalDiscountPolicy>> getDiscountPolicy() async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getDiscountPolicy();
        await localDataSource.cacheDiscountPolicy(data);
        return Right(_parseDiscountPolicy(data));
      } else {
        final cached = await localDataSource.getCachedDiscountPolicy();
        if (cached != null) return Right(_parseDiscountPolicy(cached));
        return const Left(CacheFailure(message: 'Siyosat topilmadi'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  GlobalDiscountPolicy _parseDiscountPolicy(Map<String, dynamic> data) {
    return GlobalDiscountPolicy(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      tiers: [],
      maxOverallDiscount: (data['max_overall_discount'] ?? 20).toDouble(),
      allowStacking: data['allow_stacking'] ?? false,
      maxStackCount: data['max_stack_count'] ?? 1,
      customerTypeDiscounts:
          Map<String, double>.from(data['customer_types'] ?? {}),
      isSeasonal: data['is_seasonal'] ?? false,
      isActive: data['is_active'] ?? true,
      effectiveFrom: DateTime.parse(
          data['effective_from'] ?? DateTime.now().toIso8601String()),
      createdBy: data['created_by'] ?? '',
    );
  }

  @override
  Future<Either<Failure, GlobalDiscountPolicy>> updateDiscountPolicy(
      GlobalDiscountPolicy policy) async {
    try {
      await remoteDataSource.updateDiscountPolicy({
        'name': policy.name,
        'max_overall_discount': policy.maxOverallDiscount,
        'allow_stacking': policy.allowStacking,
        'is_active': policy.isActive,
      });
      return Right(policy);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DiscountRule>> addDiscountRule(
      String agentId, DiscountRule rule) async {
    try {
      if (agentId.trim().isEmpty) {
        return const Left(
            ValidationFailure(message: 'Agent ID kiritilishi shart'));
      }
      if (rule.name.trim().isEmpty || rule.maxValue < 0) {
        return const Left(ValidationFailure(
            message:
                'Chegirma qoidasida nom va qiymat to‘g‘ri bo‘lishi shart'));
      }
      final normalizedRule = DiscountRule(
        id: rule.id.isEmpty
            ? 'rule_${DateTime.now().millisecondsSinceEpoch}'
            : rule.id,
        name: rule.name,
        type: rule.type,
        maxValue: rule.maxValue,
        condition: rule.condition,
        conditionValue: rule.conditionValue,
        requiresApproval: rule.requiresApproval,
        approvalRole: rule.approvalRole,
      );
      final list =
          _agentDiscountRules.putIfAbsent(agentId, () => <DiscountRule>[]);
      list.removeWhere((item) => item.id == normalizedRule.id);
      list.add(normalizedRule);
      return Right(normalizedRule);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> removeDiscountRule(
      String agentId, String ruleId) async {
    try {
      final list = _agentDiscountRules[agentId];
      list?.removeWhere((item) => item.id == ruleId);
      return const Right(true);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<DiscountRule>>> getGlobalDiscountRules() async {
    final rules = _agentDiscountRules.values.expand((items) => items).toList();
    return Right(rules);
  }

  // ============ SYSTEM MONITOR ============

  @override
  Future<Either<Failure, SystemHealth>> getSystemHealth() async {
    try {
      final data = await remoteDataSource.getSystemHealth();
      return Right(SystemHealth(
        status: data['status'] ?? 'healthy',
        cpuUsage: (data['cpu_usage'] ?? 0).toDouble(),
        memoryUsage: (data['memory_usage'] ?? 0).toDouble(),
        diskUsage: (data['disk_usage'] ?? 0).toDouble(),
        activeUsers: data['active_users'] ?? 0,
        totalRequests: data['total_requests'] ?? 0,
        avgResponseTime: (data['avg_response_time'] ?? 0).toDouble(),
        errorRate: (data['error_rate'] ?? 0).toDouble(),
        lastChecked: DateTime.parse(
            data['last_checked'] ?? DateTime.now().toIso8601String()),
        apiStatus: ServiceStatus(
            name: 'API',
            status: 'online',
            responseTime: 45,
            lastChecked: DateTime.now()),
        databaseStatus: ServiceStatus(
            name: 'Database',
            status: 'online',
            responseTime: 12,
            lastChecked: DateTime.now()),
        oneCStatus: ServiceStatus(
            name: '1C',
            status: data['1c_status'] ?? 'online',
            responseTime: 120,
            lastChecked: DateTime.now()),
        sapStatus: ServiceStatus(
            name: 'SAP',
            status: data['sap_status'] ?? 'online',
            responseTime: 89,
            lastChecked: DateTime.now()),
        firebaseStatus: ServiceStatus(
            name: 'Firebase',
            status: 'online',
            responseTime: 34,
            lastChecked: DateTime.now()),
      ));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<SystemAlert>>> getActiveAlerts() async {
    try {
      final data = await remoteDataSource.getActiveAlerts();
      await localDataSource.cacheAlerts(data);
      return Right(data
          .map((d) => SystemAlert(
                id: d['id'] ?? '',
                type: d['type'] ?? 'info',
                category: d['category'] ?? 'system',
                title: d['title'] ?? '',
                message: d['message'] ?? '',
                severity: d['severity'] ?? 'low',
                createdAt: DateTime.parse(
                    d['created_at'] ?? DateTime.now().toIso8601String()),
                isAcknowledged: d['is_acknowledged'] ?? false,
              ))
          .toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> acknowledgeAlert(String alertId) async {
    try {
      final result = await remoteDataSource.acknowledgeAlert(alertId);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ AUDIT LOG ============

  @override
  Future<Either<Failure, List<AuditLogEntry>>> getAuditLog({
    String? userId,
    String? action,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final data = await remoteDataSource.getAuditLog(
          userId: userId, action: action, page: page);
      return Right(data
          .map((d) => AuditLogEntry(
                id: d['id'] ?? '',
                userId: d['user_id'] ?? '',
                userName: d['user_name'] ?? '',
                userRole: d['user_role'] ?? '',
                action: d['action'] ?? '',
                entity: d['entity'] ?? '',
                entityId: d['entity_id'] ?? '',
                description: d['description'] ?? '',
                timestamp: DateTime.parse(
                    d['timestamp'] ?? DateTime.now().toIso8601String()),
              ))
          .toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ ROLES ============

  @override
  Future<Either<Failure, List<AdminRole>>> getAllRoles() async =>
      const Right([]);
  @override
  Future<Either<Failure, AdminRole>> createRole(AdminRole role) async =>
      Right(role);
  @override
  Future<Either<Failure, AdminRole>> updateRole(AdminRole role) async =>
      Right(role);
  @override
  Future<Either<Failure, bool>> deleteRole(String roleId) async =>
      const Right(true);
  @override
  Future<Either<Failure, bool>> assignRoleToUser(
          String userId, String roleId) async =>
      const Right(true);

  // ============ REPORTS ============

  @override
  Future<Either<Failure, AdminSalesReport>> getSalesReport(
      {required DateTime fromDate,
      required DateTime toDate,
      String? agentId,
      String? regionId}) async {
    try {
      final data = await remoteDataSource.getSalesReport(
        fromDate: fromDate.toIso8601String().substring(0, 10),
        toDate: toDate.toIso8601String().substring(0, 10),
      );
      return Right(AdminSalesReport(
        fromDate: fromDate,
        toDate: toDate,
        totalSales: (data['total_sales'] ?? 0).toDouble(),
        totalOrders: data['total_orders'] ?? 0,
        avgOrderValue: (data['avg_order_value'] ?? 0).toDouble(),
        dailySales: [],
        categorySales: [],
        regionSales: [],
      ));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AdminAgentPerformance>> getAgentPerformance(
      {required String agentId,
      required DateTime fromDate,
      required DateTime toDate}) async {
    try {
      final data = await remoteDataSource.getAgentPerformance(
        agentId,
        fromDate: fromDate.toIso8601String().substring(0, 10),
        toDate: toDate.toIso8601String().substring(0, 10),
      );
      return Right(AdminAgentPerformance(
        agentId: agentId,
        agentName: data['agent_name'] ?? '',
        fromDate: fromDate,
        toDate: toDate,
        totalSales: (data['total_sales'] ?? 0).toDouble(),
        salesTarget: (data['sales_target'] ?? 0).toDouble(),
        salesProgress: (data['sales_progress'] ?? 0).toDouble(),
        totalOrders: data['total_orders'] ?? 0,
        avgOrderValue: (data['avg_order_value'] ?? 0).toDouble(),
        totalVisits: data['total_visits'] ?? 0,
        visitCompletionRate: (data['visit_completion_rate'] ?? 0).toDouble(),
        totalCollections: (data['total_collections'] ?? 0).toDouble(),
        collectionRate: (data['collection_rate'] ?? 0).toDouble(),
        newCustomers: data['new_customers'] ?? 0,
        rating: (data['rating'] ?? 0).toDouble(),
        dailyPerformance: [],
      ));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<AdminTopProduct>>> getTopProducts(
          {required DateTime fromDate,
          required DateTime toDate,
          int limit = 10}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<AdminTopCustomer>>> getTopCustomers(
          {required DateTime fromDate,
          required DateTime toDate,
          int limit = 10}) async =>
      const Right([]);

  // ============ SYNC ============

  @override
  Future<Either<Failure, SyncStatus>> getSyncStatus() async {
    final recent = _syncLogs.take(10).toList();
    final last1C = _syncLogs
        .where((log) => log.system == '1c' || log.system == 'all')
        .map((log) => log.timestamp)
        .firstOrNull;
    final lastSAP = _syncLogs
        .where((log) => log.system == 'sap' || log.system == 'all')
        .map((log) => log.timestamp)
        .firstOrNull;
    return Right(SyncStatus(
      is1CConnected: true,
      isSAPConnected: true,
      last1CSync: last1C,
      lastSAPSync: lastSAP,
      pendingItems: 0,
      failedItems: recent.where((log) => log.hasErrors).length,
      recentLogs: recent,
    ));
  }

  @override
  Future<Either<Failure, bool>> triggerSync(String system) async {
    final normalized = system.toLowerCase();
    final startedAt = DateTime.now();
    _syncLogs.insert(
        0,
        SyncLogEntry(
          id: 'sync_${startedAt.microsecondsSinceEpoch}',
          system: normalized,
          action: 'manual_sync',
          status: 'success',
          itemsProcessed: 0,
          itemsFailed: 0,
          timestamp: startedAt,
          duration: DateTime.now().difference(startedAt),
        ));
    return const Right(true);
  }

  @override
  Future<Either<Failure, List<SyncLogEntry>>> getSyncLog(
          {int limit = 50}) async =>
      Right(_syncLogs.take(limit).toList());

  // ============ BULK ============

  @override
  Future<Either<Failure, BulkOperationResult>> bulkUpdateAgentRestrictions(
      {required List<String> agentIds,
      required AgentRestrictions restrictions}) async {
    return Right(BulkOperationResult(
      total: agentIds.length,
      success: agentIds.length,
      failed: 0,
      errors: [],
      duration: Duration.zero,
    ));
  }

  @override
  Future<Either<Failure, BulkOperationResult>> bulkBlockAgents(
      {required List<String> agentIds, required String reason}) async {
    return Right(BulkOperationResult(
      total: agentIds.length,
      success: agentIds.length,
      failed: 0,
      errors: [],
      duration: Duration.zero,
    ));
  }

  // ============ SUPERVISOR ============
  @override
  Future<Either<Failure, List<AdminSupervisor>>> getAllSupervisors() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, AdminSupervisor>> createSupervisor(
      CreateSupervisorParams params) async {
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, AdminSupervisor>> updateSupervisor(
      String id, UpdateSupervisorParams params) async {
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, bool>> deleteSupervisor(String id) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, PerformanceMetrics>> getPerformanceMetrics(
      {String? period}) async {
    return const Left(ServerFailure(message: 'Not implemented'));
  }
}
