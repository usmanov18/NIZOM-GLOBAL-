import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_entities.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> loginWithCredentials(
      String login, String password);
  Future<Either<Failure, bool>> sendOTP(String phone);
  Future<Either<Failure, AuthUser>> verifyOTP(String phone, String otp);
  Future<Either<Failure, bool>> isLoggedIn();
  Future<Either<Failure, String?>> getUserRole();
  Future<Either<Failure, AuthUser?>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> resetPassword(String phone);
  Future<Either<Failure, bool>> changePassword(
      String oldPassword, String newPassword);
  Future<Either<Failure, bool>> isBiometricEnabled();
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled);
  Future<Either<Failure, String?>> getAccessToken();
  Future<Either<Failure, String?>> getSapToken();
  Future<Either<Failure, String?>> getOneCToken();
}
