import 'package:flutter/material.dart';

class ClockDriftOverlay extends StatelessWidget {
  const ClockDriftOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red[900]?.withValues(alpha: 0.98),
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_toggle_off, color: Colors.white, size: 64),
            SizedBox(height: 24),
            Text(
              'VAQT XATOLIGI!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Telefoningiz vaqti server vaqtidan juda katta farq qilmoqda. Xavfsizlik yuzasidan tizim bloklandi. Iltimos, sozlamalardan "Avtomatik vaqt"ni yoqing.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
