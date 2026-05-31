import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_info_banner.dart';

class WarehouseResolutionBanner extends StatelessWidget {
  final bool hasMatch;
  final String message;
  final bool loading;

  const WarehouseResolutionBanner({
    super.key,
    required this.hasMatch,
    required this.message,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const LinearProgressIndicator(minHeight: 2);
    return hasMatch
        ? AppInfoBanner(message: message, icon: Icons.warehouse)
        : AppInfoBanner.warning(message);
  }
}
