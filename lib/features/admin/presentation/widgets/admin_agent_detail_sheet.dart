import 'package:flutter/material.dart';

class AdminAgentDetailSheet extends StatelessWidget {
  final Map<String, dynamic> agent;
  final Widget portfolioPreview;
  final bool isAdmin;
  final bool isLocalProfile;
  final VoidCallback? onEdit;
  final VoidCallback? onResetPassword;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDeleteLocal;

  const AdminAgentDetailSheet({
    super.key,
    required this.agent,
    required this.portfolioPreview,
    required this.isAdmin,
    required this.isLocalProfile,
    this.onEdit,
    this.onResetPassword,
    this.onToggleStatus,
    this.onDeleteLocal,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
                child: Text(agent['name'].toString().substring(0, 1),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0))),
              ),
            ),
            const SizedBox(height: 16),
            Center(
                child: Text(agent['name'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))),
            Center(
                child: Text('${agent['code']} • ${agent['region']}',
                    style: TextStyle(color: Colors.grey.shade600))),
            const SizedBox(height: 24),
            _detailSection('Aloqa', [
              _detailItem(Icons.phone, agent['phone']),
              _detailItem(Icons.email, agent['email']),
              _detailItem(Icons.location_on, agent['region']),
              _detailItem(Icons.supervisor_account,
                  'Supervisor: ${agent['supervisor']}'),
            ]),
            _detailSection('Statistika', [
              _detailItem(
                  Icons.shopping_bag, 'Buyurtmalar: ${agent['orders']}'),
              _detailItem(Icons.attach_money, 'Sotuv: ${agent['sales']} so\'m'),
              _detailItem(Icons.people, 'Mijozlar: ${agent['customers']}'),
              _detailItem(Icons.location_on, 'Tashriflar: ${agent['visits']}'),
              _detailItem(Icons.star, 'Reyting: ${agent['rating']}'),
            ]),
            portfolioPreview,
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: isAdmin ? onEdit : null,
                      icon: const Icon(Icons.edit),
                      label: const Text('Tahrirlash'))),
              const SizedBox(width: 12),
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: isAdmin ? onResetPassword : null,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Parol'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6F00)))),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isAdmin ? onToggleStatus : null,
                icon: Icon(agent['status'] == 'blocked'
                    ? Icons.check_circle
                    : Icons.block),
                label: Text(agent['status'] == 'blocked'
                    ? 'Faollashtirish'
                    : 'Bloklash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: agent['status'] == 'blocked'
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (isAdmin && isLocalProfile) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onDeleteLocal,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Local profilni o‘chirish'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      const SizedBox(height: 8),
      ...children,
      const SizedBox(height: 16),
    ]);
  }

  Widget _detailItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14))),
      ]),
    );
  }
}
