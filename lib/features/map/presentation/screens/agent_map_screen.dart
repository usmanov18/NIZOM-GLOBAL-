import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Agentlar xaritasi - Real vaqt GPS kuzatish
class AgentMapScreen extends StatefulWidget {
  const AgentMapScreen({super.key});

  @override
  State<AgentMapScreen> createState() => _AgentMapScreenState();
}

class _AgentMapScreenState extends State<AgentMapScreen> {
  GoogleMapController? _mapController;
  String _selectedFilter = 'all';
  bool _showAgentList = true;

  final List<Map<String, dynamic>> _agents = [
    {
      'id': '1',
      'name': 'Agent 1',
      'status': 'on_route',
      'lat': 41.2995,
      'lng': 69.2401,
      'orders': 8,
      'visits': 5
    },
    {
      'id': '2',
      'name': 'Agent 2',
      'status': 'visiting',
      'lat': 41.3050,
      'lng': 69.2500,
      'orders': 6,
      'visits': 4
    },
    {
      'id': '3',
      'name': 'Agent 3',
      'status': 'break',
      'lat': 41.3100,
      'lng': 69.2300,
      'orders': 4,
      'visits': 3
    },
    {
      'id': '4',
      'name': 'Agent 4',
      'status': 'online',
      'lat': 41.2900,
      'lng': 69.2600,
      'orders': 10,
      'visits': 7
    },
    {
      'id': '5',
      'name': 'Agent 5',
      'status': 'offline',
      'lat': 41.3150,
      'lng': 69.2200,
      'orders': 0,
      'visits': 0
    },
    {
      'id': '6',
      'name': 'Agent 6',
      'status': 'visiting',
      'lat': 41.3000,
      'lng': 69.2450,
      'orders': 7,
      'visits': 6
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agentlar xaritasi'),
        actions: [
          IconButton(
            icon: Icon(_showAgentList ? Icons.map : Icons.list),
            onPressed: () => setState(() => _showAgentList = !_showAgentList),
          ),
          IconButton(
              icon: const Icon(Icons.my_location), onPressed: _centerMap),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {})),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(41.2995, 69.2401),
              zoom: 12,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _buildMarkers(),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),

          // Filter chips
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Barchasi', 'all'),
                  const SizedBox(width: 8),
                  _filterChip('Online', 'online'),
                  const SizedBox(width: 8),
                  _filterChip('Yo\'lda', 'on_route'),
                  const SizedBox(width: 8),
                  _filterChip('Tashrifda', 'visiting'),
                  const SizedBox(width: 8),
                  _filterChip('Offline', 'offline'),
                ],
              ),
            ),
          ),

          // Bottom panel
          if (_showAgentList)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomPanel(),
            ),
        ],
      ),
    );
  }

  Widget _agentMarker(Map<String, dynamic> agent) {
    Color color;
    switch (agent['status']) {
      case 'on_route':
        color = const Color(0xFF2196F3);
        break;
      case 'visiting':
        color = const Color(0xFFFF9800);
        break;
      case 'break':
        color = const Color(0xFF9E9E9E);
        break;
      case 'online':
        color = const Color(0xFF4CAF50);
        break;
      default:
        color = const Color(0xFFE53935);
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)
            ],
          ),
          child: Center(
            child: Text(
              agent['name'].toString().split(' ').last,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)
            ],
          ),
          child: Text(
            agent['name'],
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final filteredAgents = _selectedFilter == 'all'
        ? _agents
        : _agents.where((a) => a['status'] == _selectedFilter).toList();

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _panelStat(
                    'Online',
                    '${_agents.where((a) => a['status'] != 'offline').length}',
                    const Color(0xFF4CAF50)),
                _panelStat(
                    'Yo\'lda',
                    '${_agents.where((a) => a['status'] == 'on_route').length}',
                    const Color(0xFF2196F3)),
                _panelStat(
                    'Tashrifda',
                    '${_agents.where((a) => a['status'] == 'visiting').length}',
                    const Color(0xFFFF9800)),
                _panelStat(
                    'Offline',
                    '${_agents.where((a) => a['status'] == 'offline').length}',
                    const Color(0xFFE53935)),
              ],
            ),
          ),

          // Agent list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredAgents.length,
              itemBuilder: (context, index) =>
                  _buildAgentTile(filteredAgents[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label,
            style:
                TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }

  Widget _buildAgentTile(Map<String, dynamic> agent) {
    Color statusColor;
    String statusText;

    switch (agent['status']) {
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
      case 'online':
        statusColor = const Color(0xFF4CAF50);
        statusText = 'Online';
        break;
      default:
        statusColor = const Color(0xFFE53935);
        statusText = 'Offline';
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.1),
        child: Text(agent['id'],
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
      ),
      title: Text(agent['name'],
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Row(
        children: [
          Icon(Icons.circle, size: 8, color: statusColor),
          const SizedBox(width: 4),
          Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
          const SizedBox(width: 8),
          Text('${agent['orders']} buyurtma • ${agent['visits']} tashrif',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              icon: const Icon(Icons.navigation, size: 18),
              onPressed: () => _focusAgent(agent),
              color: const Color(0xFF00897B)),
          IconButton(
              icon: const Icon(Icons.call, size: 18),
              onPressed: () => _showCallSnack(agent),
              color: const Color(0xFF2E7D32)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredAgents {
    if (_selectedFilter == 'all') return _agents;
    return _agents
        .where((agent) => agent['status'] == _selectedFilter)
        .toList();
  }

  Set<Marker> _buildMarkers() {
    return _filteredAgents.map((agent) {
      final lat = (agent['lat'] as num).toDouble();
      final lng = (agent['lng'] as num).toDouble();
      return Marker(
        markerId: MarkerId(agent['id'].toString()),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            _markerHue(agent['status'].toString())),
        infoWindow: InfoWindow(
          title: agent['name'].toString(),
          snippet: '${agent['orders']} buyurtma • ${agent['visits']} tashrif',
        ),
        onTap: () => _focusAgent(agent, zoom: false),
      );
    }).toSet();
  }

  double _markerHue(String status) {
    switch (status) {
      case 'on_route':
        return BitmapDescriptor.hueAzure;
      case 'visiting':
        return BitmapDescriptor.hueOrange;
      case 'break':
        return BitmapDescriptor.hueYellow;
      case 'online':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  Future<void> _centerMap() async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(const LatLng(41.2995, 69.2401), 12),
    );
  }

  Future<void> _focusAgent(Map<String, dynamic> agent,
      {bool zoom = true}) async {
    final lat = (agent['lat'] as num).toDouble();
    final lng = (agent['lng'] as num).toDouble();
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), zoom ? 15 : 13),
    );
  }

  void _showCallSnack(Map<String, dynamic> agent) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${agent['name']} bilan aloqa funksiyasi tanlandi')),
    );
  }
}
