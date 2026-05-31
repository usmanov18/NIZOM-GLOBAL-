import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/config/env_config.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../products/domain/entities/product_portfolio.dart';
import '../../../products/domain/repositories/product_portfolio_repository.dart';
import '../../data/datasources/sales_user_profile_local_datasource.dart';
import '../../domain/entities/user_portfolio_profile.dart';

class AdminAgentsController extends ChangeNotifier {
  String actorRole = 'unknown';
  bool assignmentsLoading = false;
  List<SalesUserProfile> savedProfiles = [];
  final Map<String, PortfolioAssignment> assignmentCache = {};

  bool get isAdmin => actorRole == 'admin';

  Future<void> initialize() async {
    actorRole = await currentActorRole();
    notifyListeners();
    await loadSavedProfiles();
    await loadAssignmentCache(getAgents());
  }

  Future<String> currentActorRole() async {
    final result = await getIt<AuthRepository>().getCurrentUser();
    return result.fold((_) => 'unknown', (user) => user?.role ?? 'unknown');
  }

  Future<void> loadSavedProfiles() async {
    savedProfiles =
        await getIt<SalesUserProfileLocalDataSource>().getProfiles();
    notifyListeners();
  }

  Future<void> loadAssignmentCache(List<Map<String, dynamic>> agents) async {
    assignmentsLoading = true;
    notifyListeners();
    final cache = <String, PortfolioAssignment>{};
    for (final agent in agents) {
      final id = agent['id']?.toString() ?? '';
      cache[id] = await loadAssignment(id, 'agent');
    }
    assignmentCache
      ..clear()
      ..addAll(cache);
    assignmentsLoading = false;
    notifyListeners();
  }

  ProductPortfolioRepository get portfolioRepository =>
      getIt<ProductPortfolioRepository>();

  Future<List<ProductPortfolio>> loadPortfolios() async {
    final result = await portfolioRepository.getPortfolios();
    return result.fold(
        (_) => portfolioRepository.demoPortfolios, (items) => items);
  }

  Future<PortfolioAssignment> loadAssignment(String userId, String role) async {
    final result = await portfolioRepository.getAssignmentForUser(userId, role);
    return result.fold(
      (_) => PortfolioAssignment(
        id: 'fallback_${role}_$userId',
        userId: userId,
        userRole: role,
        portfolioIds: const [],
        assignedAt: DateTime.now(),
        assignedBy: 'system',
      ),
      (assignment) => assignment,
    );
  }

  Future<void> savePortfolioAssignment(PortfolioAssignment assignment) async {
    final role = await currentActorRole();
    final result = await portfolioRepository.saveAssignment(
        actorRole: role, assignment: assignment);
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<void> saveProfile(SalesUserProfile profile) async {
    await getIt<SalesUserProfileLocalDataSource>().saveProfile(profile);
    await loadSavedProfiles();
    await loadAssignmentCache(getAgents());
  }

  Future<void> toggleProfileStatus(String id) async {
    final ds = getIt<SalesUserProfileLocalDataSource>();
    final existing = await ds.getProfileById(id);
    if (existing == null) throw Exception('Demo profil statusi saqlanmaydi');
    await ds.saveProfile(existing.copyWith(isActive: !existing.isActive));
    await loadSavedProfiles();
    await loadAssignmentCache(getAgents());
  }

  Future<void> deleteProfile(String id) async {
    await getIt<SalesUserProfileLocalDataSource>().deleteProfile(id);
    await loadSavedProfiles();
    await loadAssignmentCache(getAgents());
  }

  List<Map<String, dynamic>> getAgents() {
    final demoAgents = List.generate(
        15,
        (i) => {
              'id': 'ag${(i + 1).toString().padLeft(3, '0')}',
              'code': 'AG${(i + 1).toString().padLeft(3, '0')}',
              'name': 'Agent ${i + 1}',
              'phone': '+998 90 ${100 + i} ${10 + i} ${20 + i}',
              'email': 'agent${i + 1}@nizomglobal.uz',
              'region': i % 3 == 0
                  ? 'Toshkent'
                  : i % 3 == 1
                      ? 'Samarqand'
                      : 'Buxoro',
              'role': 'agent',
              'supervisor': i % 2 == 0 ? 'Menejerov' : 'Supervisorov',
              'status': i < 12
                  ? 'active'
                  : i < 14
                      ? 'inactive'
                      : 'blocked',
              'orders': (i + 1) * 8,
              'sales': (i + 1) * 45000000,
              'customers': (i + 1) * 12,
              'visits': (i + 1) * 15,
              'rating': 4.0 + (i % 10) / 10,
              'portfolioIds': i % 5 == 0
                  ? <String>['pf_energy_premium']
                  : i % 3 == 0
                      ? <String>['pf_beverages', 'pf_energy_premium']
                      : i % 2 == 0
                          ? <String>['pf_beverages', 'pf_snacks']
                          : <String>['pf_beverages'],
            });
    final saved = savedProfiles.map(_profileToAgentMap).toList();
    if (!EnvConfig.isDemoMode) return saved;
    final savedIds = saved.map((e) => e['id']).toSet();
    return [
      ...saved,
      ...demoAgents.where((agent) => !savedIds.contains(agent['id']))
    ];
  }

  Map<String, dynamic> _profileToAgentMap(SalesUserProfile profile) => {
        'id': profile.id,
        'code': profile.code ?? profile.id.toUpperCase(),
        'name': profile.fullName,
        'phone': profile.phone,
        'email': '${profile.id}@nizomglobal.uz',
        'region': profile.regionName ?? _regionName(profile.regionId ?? ''),
        'supervisor': profile.supervisorId ?? '—',
        'status': profile.isActive ? 'active' : 'inactive',
        'orders': 0,
        'sales': 0,
        'customers': 0,
        'visits': 0,
        'rating': 0.0,
        'role': profile.role,
        'portfolioIds': profile.portfolioAssignment.portfolioIds,
      };

  String _regionName(String regionId) {
    switch (regionId) {
      case 'tashkent':
        return 'Toshkent';
      case 'samarkand':
        return 'Samarqand';
      case 'bukhara':
        return 'Buxoro';
      default:
        return regionId;
    }
  }
}
