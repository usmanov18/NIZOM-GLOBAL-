import 'package:flutter/material.dart';
import '../design/app_design_tokens.dart';

class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool compact;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.compact = false,
  });

  factory AppStatusBadge.success(String label,
          {IconData? icon, bool compact = false}) =>
      AppStatusBadge(
          label: label,
          color: AppColors.success,
          icon: icon ?? Icons.check_circle,
          compact: compact);

  factory AppStatusBadge.warning(String label,
          {IconData? icon, bool compact = false}) =>
      AppStatusBadge(
          label: label,
          color: AppColors.warning,
          icon: icon ?? Icons.warning_amber,
          compact: compact);

  factory AppStatusBadge.danger(String label,
          {IconData? icon, bool compact = false}) =>
      AppStatusBadge(
          label: label,
          color: AppColors.danger,
          icon: icon ?? Icons.error,
          compact: compact);

  factory AppStatusBadge.info(String label,
          {IconData? icon, bool compact = false}) =>
      AppStatusBadge(
          label: label,
          color: AppColors.primary,
          icon: icon ?? Icons.info,
          compact: compact);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 9,
        vertical: compact ? 2 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 15, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
