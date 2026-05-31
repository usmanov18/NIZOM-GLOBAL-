import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/delivery_bloc.dart';
import '../../domain/entities/delivery_entities.dart';

/// Haydovchi Bosh sahifa - To'liq Dashboard
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DeliveryBloc>().add(DeliveryDashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Yetkazib berish'),
        automaticallyImplyLeading: false,
        actions: [
          BlocBuilder<DeliveryBloc, DeliveryState>(
            builder: (context, state) {
              final isTracking =
                  state is DeliveryTrackingActive && state.isActive;
              return IconButton(
                icon: Icon(
                  isTracking ? Icons.gps_fixed : Icons.gps_off,
                  color: isTracking ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  if (isTracking) {
                    context
                        .read<DeliveryBloc>()
                        .add(DeliveryTrackingStopRequested());
                  } else {
                    context
                        .read<DeliveryBloc>()
                        .add(DeliveryTrackingStartRequested());
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context
                .read<DeliveryBloc>()
                .add(DeliveryDashboardRefreshRequested()),
          ),
        ],
      ),
      body: BlocBuilder<DeliveryBloc, DeliveryState>(
        builder: (context, state) {
          if (state is DeliveryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DeliveryDashboardLoaded) {
            return _buildDashboard(context, state);
          }
          return const Center(child: Text('Yuklanmoqda...'));
        },
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, DeliveryDashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DeliveryBloc>().add(DeliveryDashboardRefreshRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            _buildStatusCard(state.driverStatus),
            const SizedBox(height: 16),

            // Stats
            _buildStatsRow(state.driverStatus),
            const SizedBox(height: 16),

            // Route progress
            if (state.todayRoute != null)
              _buildRouteProgress(state.todayRoute!),
            const SizedBox(height: 16),

            // Quick actions
            _buildQuickActions(context),
            const SizedBox(height: 16),

            // Today deliveries
            _buildTodayDeliveries(state.todayDeliveries),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(DriverStatus status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status.status) {
      case 'on_route':
        statusColor = const Color(0xFF2196F3);
        statusText = 'Yo\'lda';
        statusIcon = Icons.local_shipping;
        break;
      case 'delivering':
        statusColor = const Color(0xFFFF9800);
        statusText = 'Yetkazilmoqda';
        statusIcon = Icons.home;
        break;
      case 'break':
        statusColor = const Color(0xFF9E9E9E);
        statusText = 'Tanaffus';
        statusIcon = Icons.coffee;
        break;
      default:
        statusColor = const Color(0xFF4CAF50);
        statusText = 'Tayyor';
        statusIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: statusColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusText,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      status.currentCustomerName ?? 'Keyingi manzilga',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (status.etaMinutes != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${status.etaMinutes} min',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          if (status.distanceToNextStop != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statusStat('Masofa',
                    '${status.distanceToNextStop!.toStringAsFixed(1)} km'),
                _statusStat('Vaqt', '${status.etaMinutes ?? 0} min'),
                _statusStat('Yo\'nalish', 'Chilonzor tumani'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }

  Widget _buildStatsRow(DriverStatus status) {
    return Row(
      children: [
        Expanded(
            child: _statCard('Jami', '${status.todayDeliveries}',
                Icons.local_shipping, const Color(0xFF1565C0))),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard('Bajarildi', '${status.todayCompleted}',
                Icons.check_circle, const Color(0xFF2E7D32))),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard('Qoldi', '${status.todayPending}', Icons.pending,
                const Color(0xFFFF6F00))),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard(
                'Masofa',
                '${status.todayDistance.toStringAsFixed(0)}km',
                Icons.route,
                const Color(0xFF00897B))),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 5)
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildRouteProgress(DeliveryRoute route) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Marshrut',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text('${route.completedStops}/${route.totalStops}',
                  style: const TextStyle(
                      color: Color(0xFF00897B), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: route.completionRate,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF00897B)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _routeStat(
                  'Masofa', '${route.totalDistanceKm.toStringAsFixed(1)} km'),
              _routeStat('Vaqt', '${route.totalTimeMinutes} min'),
              _routeStat('Status', route.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _routeStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionButton('Marshrut', Icons.map, const Color(0xFF00897B),
              () => context.go('/delivery/route')),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton('Navigatsiya', Icons.navigation,
              const Color(0xFF1565C0), () => context.go('/delivery/map')),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton('Xarita', Icons.location_on,
              const Color(0xFFFF6F00), () => context.go('/delivery/map')),
        ),
      ],
    );
  }

  Widget _actionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayDeliveries(List<DeliveryOrder> deliveries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bugungi yetkazishlar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('${deliveries.length} ta',
                style: const TextStyle(
                    color: Color(0xFF00897B), fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        ...deliveries.map((delivery) => _buildDeliveryCard(delivery)),
      ],
    );
  }

  Widget _buildDeliveryCard(DeliveryOrder delivery) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (delivery.status) {
      case DeliveryStatus.assigned:
        statusColor = const Color(0xFF1565C0);
        statusText = 'Tayinlangan';
        statusIcon = Icons.assignment;
        break;
      case DeliveryStatus.picked:
        statusColor = const Color(0xFFFF9800);
        statusText = 'Olingan';
        statusIcon = Icons.inventory;
        break;
      case DeliveryStatus.inTransit:
        statusColor = const Color(0xFF2196F3);
        statusText = 'Yo\'lda';
        statusIcon = Icons.local_shipping;
        break;
      case DeliveryStatus.delivered:
        statusColor = const Color(0xFF2E7D32);
        statusText = 'Yetkazildi';
        statusIcon = Icons.check_circle;
        break;
      case DeliveryStatus.failed:
        statusColor = const Color(0xFFC62828);
        statusText = 'Muvaffaqiyatsiz';
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Kutilmoqda';
        statusIcon = Icons.hourglass_empty;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: InkWell(
        onTap: () => _showDeliveryDetail(delivery),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(delivery.orderNumber,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(delivery.customerName,
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 12)),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(delivery.deliveryAddress,
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(statusText,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 4),
                      Text(delivery.scheduledTimeSlot,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _deliveryInfo(
                      Icons.shopping_bag, '${delivery.totalItems} ta'),
                  const SizedBox(width: 16),
                  _deliveryInfo(Icons.attach_money,
                      '${(delivery.totalAmount / 1000000).toStringAsFixed(1)}M'),
                  const Spacer(),
                  if (delivery.status == DeliveryStatus.assigned)
                    ElevatedButton.icon(
                      onPressed: () => context.read<DeliveryBloc>().add(
                          DeliveryPickOrderRequested(deliveryId: delivery.id)),
                      icon: const Icon(Icons.inventory, size: 16),
                      label: const Text('Olish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  if (delivery.status == DeliveryStatus.picked)
                    ElevatedButton.icon(
                      onPressed: () => context.read<DeliveryBloc>().add(
                          DeliveryDepartRequested(
                              deliveryId: delivery.id,
                              latitude: delivery.deliveryLatitude ?? 41.2995,
                              longitude:
                                  delivery.deliveryLongitude ?? 69.2401)),
                      icon: const Icon(Icons.navigation, size: 16),
                      label: const Text('Yo\'lga chiqish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  if (delivery.status == DeliveryStatus.inTransit)
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.push(_deliveryConfirmRoute(delivery)),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Yetkazildi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
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

  String _deliveryConfirmRoute(DeliveryOrder delivery) {
    final customer = Uri.encodeComponent(delivery.customerName);
    return '/delivery/confirm?id=${delivery.id}&order=${delivery.orderNumber}&customer=$customer&amount=${delivery.totalAmount}';
  }

  Widget _deliveryInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  void _showDeliveryDetail(DeliveryOrder delivery) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(delivery.orderNumber,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(delivery.customerName),
            Text(delivery.deliveryAddress,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Text(
                'Jami: ${(delivery.totalAmount / 1000000).toStringAsFixed(1)}M so‘m'),
            Text('Vaqt: ${delivery.scheduledTimeSlot}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/delivery/route');
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Xarita'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(_deliveryConfirmRoute(delivery));
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Tasdiqlash'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
