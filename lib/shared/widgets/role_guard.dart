import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../features/auth/domain/entities/auth_entities.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../core/security/role_permission_policy.dart';

/// Role asosida ekranlarni himoyalash uchun reusable widget.
class RoleGuard extends StatelessWidget {
  final List<String> allowedRoles;
  final String? requiredFeature;
  final Widget child;
  final String title;
  final String message;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    this.requiredFeature,
    required this.child,
    this.title = 'Ruxsat yo‘q',
    this.message = 'Bu bo‘limga kirish uchun sizda yetarli huquq yo‘q.',
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user =
            snapshot.data?.fold<AuthUser?>((_) => null, (value) => value);
        final role = user?.role ?? 'unknown';
        final allowedByRole = allowedRoles.contains(role);
        final allowedByFeature = requiredFeature == null ||
            RolePermissionPolicy.canAccessFeature(role, requiredFeature!);
        if (!allowedByRole || !allowedByFeature) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 72, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('$message\n\nSizning rolingiz: $role',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
