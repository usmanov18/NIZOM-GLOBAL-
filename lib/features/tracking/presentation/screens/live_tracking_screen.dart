import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tracking_bloc.dart';
import '../../domain/entities/tracking_entities.dart';

/// Real vaqt xarita - Agentlarni kuzatish
class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _mapController;
  String _filterStatus = 'all';
  bool _showList = false;

  @override
  void initState() {
    super.initState();
    context.read<TrackingBloc>().add(TrackingStartRequested());
  }

  @override
  void dispose() {
    context.read<TrackingBloc>().add(TrackingStopRequested());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agentlar xaritasi'),
        actions: [
          IconButton(
            icon: Icon(_showList ? Icons.map : Icons.list),
            onPressed: () => setState(() => _showList = !_showList),
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerMap,
          ),
        ],
      ),
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          if (state is TrackingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TrackingActive) {
            return _showList
                ? _buildListView(state.agents)
                : _buildMapView(state);
          }
          return const Center(child: Text('Tracking boshlanmadi'));
        },
      ),
    );
  }

  Widget _buildMapView(TrackingActive state) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(41.2995, 69.2401),
            zoom: 12,
          ),
          onMapCreated: (controller) => _mapController = controller,
          markers: _buildMarkers(state.agents),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
        ),

        // Filters
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('Barchasi', 'all', state.agents.length),
                const SizedBox(width: 8),
                _filterChip('Online', 'online', state.onlineCount),
                const SizedBox(width: 8),
                _filterChip('Yo\'lda', 'on_route',
                    state.agents.where((a) => a.status == 'on_route').length),
                const SizedBox(width: 8),
                _filterChip('Offline', 'offline', state.offlineCount),
              ],
            ),
          ),
        ),

        // Bottom panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomPanel(state),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value, int count) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontSize: 12)),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white : Colors.grey.shade600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(TrackingActive state) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _panelStat(
                    'Online', '${state.onlineCount}', const Color(0xFF4CAF50)),
                _panelStat(
                    'Yo\'lda',
                    '${state.agents.where((a) => a.status == 'on_route').length}',
                    const Color(0xFF2196F3)),
                _panelStat(
                    'Tashrifda',
                    '${state.agents.where((a) => a.status == 'visiting').length}',
                    const Color(0xFFFF9800)),
                _panelStat('Offline', '${state.offlineCount}',
                    const Color(0xFFE53935)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.agents.length,
              itemBuilder: (context, index) =>
                  _buildAgentTile(state.agents[index]),
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

  Widget _buildAgentTile(AgentLiveStatus agent) {
    Color statusColor;
    String statusText;

    switch (agent.status) {
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
        child: Text(agent.agentName.substring(0, 1),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
      ),
      title: Text(agent.agentName,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Row(
        children: [
          Icon(Icons.circle, size: 8, color: statusColor),
          const SizedBox(width: 4),
          Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
          if (agent.speed != null && agent.speed! > 0) ...[
            const SizedBox(width: 8),
            Text('${agent.speed!.toStringAsFixed(0)} km/h',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (agent.batteryLevel != null)
            Icon(
              agent.batteryLevel! > 50
                  ? Icons.battery_full
                  : Icons.battery_alert,
              color: agent.batteryLevel! > 20 ? Colors.grey : Colors.red,
              size: 18,
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.navigation, color: Color(0xFF00897B)),
            onPressed: () => _focusAgent(agent),
          ),
        ],
      ),
      onTap: () => _showAgentDetail(agent),
    );
  }

  Widget _buildListView(List<AgentLiveStatus> agents) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agents.length,
      itemBuilder: (context, index) => _buildAgentTile(agents[index]),
    );
  }

  void _showAgentDetail(AgentLiveStatus agent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
                child: Text(agent.agentName.substring(0, 1),
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0))),
              ),
              const SizedBox(height: 12),
              Text(agent.agentName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(agent.agentCode,
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _detailStat(
                      'Tezlik',
                      '${agent.speed?.toStringAsFixed(0) ?? 0} km/h',
                      Icons.speed),
                  _detailStat(
                      'Batareya',
                      '${agent.batteryLevel?.toInt() ?? 0}%',
                      Icons.battery_full),
                  _detailStat('Yangilangan', _formatTime(agent.lastUpdate),
                      Icons.update),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showActionSnack(agent, 'Qo‘ng‘iroq'),
                      icon: const Icon(Icons.call),
                      label: const Text('Qo\'ng\'iroq'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showActionSnack(agent, 'Xabar'),
                      icon: const Icon(Icons.message),
                      label: const Text('Xabar'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  List<AgentLiveStatus> _filteredLiveAgents(List<AgentLiveStatus> agents) {
    if (_filterStatus == 'all') return agents;
    return agents.where((agent) => agent.status == _filterStatus).toList();
  }

  Set<Marker> _buildMarkers(List<AgentLiveStatus> agents) {
    return _filteredLiveAgents(agents).map((agent) {
      return Marker(
        markerId: MarkerId(agent.agentId),
        position: LatLng(agent.latitude, agent.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(_markerHue(agent.status)),
        infoWindow: InfoWindow(
          title: agent.agentName,
          snippet:
              '${agent.agentCode} • ${agent.speed?.toStringAsFixed(0) ?? 0} km/h',
        ),
        onTap: () => _showAgentDetail(agent),
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

  Future<void> _focusAgent(AgentLiveStatus agent) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(agent.latitude, agent.longitude), 15),
    );
  }

  void _showActionSnack(AgentLiveStatus agent, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('$action: ${agent.agentName} funksiyasi tanlandi')),
    );
  }
}
