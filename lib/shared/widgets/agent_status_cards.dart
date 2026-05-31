import 'package:flutter/material.dart';

/// Agentlar holati kartochkalari
class AgentStatusCards extends StatelessWidget {
  final List<Map<String, dynamic>> agents;
  final VoidCallback? onViewAll;

  const AgentStatusCards({super.key, required this.agents, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Agentlar holati',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: onViewAll,
              child: const Text('Barchasi'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: agents.length,
            itemBuilder: (context, index) => _buildAgentCard(agents[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    Color statusColor;
    String statusText;

    switch (agent['status']) {
      case 'online':
        statusColor = const Color(0xFF4CAF50);
        statusText = 'Online';
        break;
      case 'on_route':
        statusColor = const Color(0xFF2196F3);
        statusText = 'Yo\'lda';
        break;
      case 'visiting':
        statusColor = const Color(0xFFFF9800);
        statusText = 'Tashrifda';
        break;
      case 'break':
        statusColor = const Color(0xFF9E9E9E);
        statusText = 'Tanaffus';
        break;
      default:
        statusColor = const Color(0xFFE53935);
        statusText = 'Offline';
    }

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: statusColor.withValues(alpha: 0.1),
                child: Text(
                  agent['name'].toString().substring(0, 1),
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            agent['name'],
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            statusText,
            style: TextStyle(color: statusColor, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
