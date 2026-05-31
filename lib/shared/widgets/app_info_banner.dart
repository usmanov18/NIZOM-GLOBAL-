import 'package:flutter/material.dart';
import '../design/app_design_tokens.dart';

class AppInfoBanner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  final Widget? trailing;

  const AppInfoBanner({
    super.key,
    required this.message,
    this.color = AppColors.primary,
    this.icon = Icons.info_outline,
    this.trailing,
  });

  factory AppInfoBanner.warning(String message, {Widget? trailing}) =>
      AppInfoBanner(
          message: message,
          color: AppColors.warning,
          icon: Icons.warning_amber,
          trailing: trailing);

  factory AppInfoBanner.danger(String message, {Widget? trailing}) =>
      AppInfoBanner(
          message: message,
          color: AppColors.danger,
          icon: Icons.error_outline,
          trailing: trailing);

  factory AppInfoBanner.success(String message, {Widget? trailing}) =>
      AppInfoBanner(
          message: message,
          color: AppColors.success,
          icon: Icons.check_circle_outline,
          trailing: trailing);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
