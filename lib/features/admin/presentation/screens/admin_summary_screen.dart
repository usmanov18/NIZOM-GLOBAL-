import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_metric_card.dart';

class AdminSummaryScreen extends StatelessWidget {
  const AdminSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bugungi Holat (Real-time)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(
                  child: AppMetricCard(
                    title: 'Bugungi Sotuv',
                    value: '1.2Mrd',
                    icon: Icons.trending_up,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AppMetricCard(
                    title: 'Faol Agentlar',
                    value: '45/50',
                    icon: Icons.people,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAgentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentList() {
    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, i) => ListTile(
          leading: CircleAvatar(child: Text('${i + 1}')),
          title: Text('Agent ${i + 1}'),
          subtitle: const Text('Oxirgi sync: 2 daq. oldin'),
          trailing: const Text(
            '24.5 mln',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
