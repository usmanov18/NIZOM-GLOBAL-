import 'package:flutter/material.dart';

class ReadOnlyBanner extends StatelessWidget {
  final String role;

  const ReadOnlyBanner({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6F00).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFFF6F00).withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility, color: Color(0xFFFF6F00), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Siz $role sifatida ma’lumotlarni faqat ko‘rasiz. Boshqarish faqat admin huquqi.',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
