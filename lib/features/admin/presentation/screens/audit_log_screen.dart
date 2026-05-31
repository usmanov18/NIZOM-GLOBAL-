import 'package:flutter/material.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tizim Audit Loglari')),
      body: const Center(child: Text('Audit loglar (Hive-dan yuklanmoqda...)')),
    );
  }
}
