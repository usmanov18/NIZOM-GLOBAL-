import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/config/env_config.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../../../admin/data/datasources/sales_user_profile_local_datasource.dart';

// ============================================================
// AUTH REPOSITORY IMPLEMENTATION
// ============================================================

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SalesUserProfileLocalDataSource? salesUserProfileLocalDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    this.salesUserProfileLocalDataSource,
  });

  @override
  Future<Either<Failure, AuthUser>> loginWithCredentials(
      String login, String password) async {
    try {
      // Admin yaratgan local profil kodi bilan demo login.
      // Masalan: AG777 / 123456
      final localProfileUser = EnvConfig.isDemoMode
          ? await _tryLoginWithLocalProfile(login, password)
          : null;
      if (localProfileUser != null) {
        await localDataSource
            .saveAccessToken('local_access_token_${localProfileUser['id']}');
        await localDataSource
            .saveRefreshToken('local_refresh_token_${localProfileUser['id']}');
        await localDataSource.saveUserData(localProfileUser);
        await localDataSource.saveUserRole(localProfileUser['role']);
        return Right(AuthUser.fromJson(localProfileUser));
      }

      // Development/demo login. Backend API tayyor bo'lmaguncha ilova oqimini
      // real BLoC/Repository orqali sinash imkonini beradi.
      if (EnvConfig.isDemoMode && _isDemoCredential(login, password)) {
        final userData = _demoUser(login);
        await localDataSource
            .saveAccessToken('demo_access_token_${userData['role']}');
        await localDataSource
            .saveRefreshToken('demo_refresh_token_${userData['role']}');
        await localDataSource.saveUserData(userData);
        await localDataSource.saveUserRole(userData['role']);
        return Right(AuthUser.fromJson(userData));
      }

      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.login(login, password);
        await localDataSource.saveAccessToken(result['access_token']);
        await localDataSource.saveRefreshToken(result['refresh_token']);
        await localDataSource.saveUserData(result['user']);
        await localDataSource.saveUserRole(result['user']['role']);
        return Right(AuthUser.fromJson(result['user']));
      } else {
        final cached = await localDataSource.getUserData();
        if (cached != null) return Right(AuthUser.fromJson(cached));
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> sendOTP(String phone) async {
    try {
      // Demo rejim: istalgan telefon uchun OTP yuborildi deb hisoblaymiz.
      if (EnvConfig.isDemoMode && phone.isNotEmpty) return const Right(true);

      final result = await remoteDataSource.sendOTP(phone);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> verifyOTP(String phone, String otp) async {
    try {
      // Demo OTP: 123456 agent sifatida kiritadi.
      if (EnvConfig.isDemoMode && otp == '123456') {
        final userData = _demoUser('agent')..['phone'] = phone;
        await localDataSource.saveAccessToken('demo_access_token_agent');
        await localDataSource.saveRefreshToken('demo_refresh_token_agent');
        await localDataSource.saveUserData(userData);
        await localDataSource.saveUserRole(userData['role']);
        return Right(AuthUser.fromJson(userData));
      }

      final result = await remoteDataSource.verifyOTP(phone, otp);
      await localDataSource.saveAccessToken(result['access_token']);
      await localDataSource.saveRefreshToken(result['refresh_token']);
      await localDataSource.saveUserData(result['user']);
      await localDataSource.saveUserRole(result['user']['role']);
      return Right(AuthUser.fromJson(result['user']));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final token = await localDataSource.getAccessToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, String?>> getUserRole() async {
    try {
      return Right(await localDataSource.getUserRole());
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      final data = await localDataSource.getUserData();
      if (data != null) return Right(AuthUser.fromJson(data));
      return const Right(null);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token != null) await remoteDataSource.logout(token);
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      await localDataSource.clearAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(String phone) async {
    try {
      return Right(await remoteDataSource.resetPassword(phone));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token == null)
        return const Left(AuthFailure(message: 'Tizimga kirmagan'));
      return Right(await remoteDataSource.changePassword(
          token, oldPassword, newPassword));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricEnabled() async {
    return Right(await localDataSource.isBiometricEnabled());
  }

  @override
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled) async {
    await localDataSource.setBiometricEnabled(enabled);
    return const Right(null);
  }

  @override
  Future<Either<Failure, String?>> getAccessToken() async {
    return Right(await localDataSource.getAccessToken());
  }

  @override
  Future<Either<Failure, String?>> getSapToken() async {
    return Right(await localDataSource.getSapToken());
  }

  @override
  Future<Either<Failure, String?>> getOneCToken() async {
    return Right(await localDataSource.getOneCToken());
  }

  Future<Map<String, dynamic>?> _tryLoginWithLocalProfile(
      String login, String password) async {
    if (password != '123456' || salesUserProfileLocalDataSource == null)
      return null;
    final normalized = login.trim().toLowerCase();
    final profiles = await salesUserProfileLocalDataSource!.getProfiles();
    final matches = profiles.where((profile) {
      return profile.id.toLowerCase() == normalized ||
          (profile.code ?? '').toLowerCase() == normalized ||
          profile.phone.replaceAll(' ', '').toLowerCase() == normalized;
    });
    if (matches.isEmpty) return null;
    final profile = matches.first;
    return {
      'id': profile.id,
      'name': profile.fullName,
      'email': '${profile.id}@nizomglobal.uz',
      'phone': profile.phone,
      'role': profile.role,
      'avatar': null,
      'region_id': profile.regionId,
      'region_name': profile.regionName,
      'warehouse_id': profile.warehouseId,
      'warehouse_name': _warehouseName(profile.warehouseId),
      'allowed_warehouse_ids': profile.allowedWarehouseIds.isEmpty
          ? [if (profile.warehouseId != null) profile.warehouseId]
          : profile.allowedWarehouseIds,
      'code': profile.code,
      'is_active': profile.isActive,
    };
  }

  String? _warehouseName(String? id) {
    switch (id) {
      case 'warehouse_1':
        return 'Asosiy ombor';
      case 'warehouse_2':
        return 'Toshkent ombor';
      case 'warehouse_3':
        return 'Samarqand ombor';
      default:
        return id;
    }
  }

  bool _isDemoCredential(String login, String password) {
    const roles = {'admin', 'supervisor', 'agent', 'delivery'};
    return roles.contains(login.trim().toLowerCase()) && password == '123456';
  }

  Map<String, dynamic> _demoUser(String login) {
    final role = login.trim().toLowerCase();
    final names = {
      'admin': 'NIZOM GLOBAL Admin',
      'supervisor': 'Supervisor',
      'agent': 'Savdo agenti',
      'delivery': 'Yetkazuvchi',
    };

    return {
      'id': 'demo_$role',
      'name': names[role] ?? 'Demo user',
      'email': '$role@nizomglobal.uz',
      'phone': '+998901234567',
      'role': role,
      'avatar': null,
      'region_id': 'region_1',
      'region_name': 'Toshkent',
      'warehouse_id': 'warehouse_1',
      'warehouse_name': 'Asosiy ombor',
      'allowed_warehouse_ids':
          role == 'agent' ? ['warehouse_1', 'warehouse_2'] : ['warehouse_1'],
      'code': role == 'agent' ? 'AG001' : role.toUpperCase(),
      'is_active': true,
    };
  }
}
