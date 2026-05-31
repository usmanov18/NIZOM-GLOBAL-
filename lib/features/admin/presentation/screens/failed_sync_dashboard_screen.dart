import 'package:flutter/material.dart';

class FailedSyncDashboardScreen extends StatelessWidget {
  const FailedSyncDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Failed Sync Dashboard')),
      body: const Center(child: Text('Failed Sync Dashboard Placeholder')),
    );
  }
}
