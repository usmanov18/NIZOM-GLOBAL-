import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification/models/notification_models.dart';
import '../../../../core/services/notification/notification_bloc.dart';

/// Bildirishnomalar — NotificationBloc/Repository orqali boshqariladi.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  NotificationType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<NotificationBloc>().add(NotificationInitialize());
    _load();
  }

  void _load({bool? isRead, NotificationType? type}) {
    context
        .read<NotificationBloc>()
        .add(NotificationLoadRequested(isRead: isRead, type: type));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationBloc, NotificationState>(
      listener: _onNotificationState,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
                'Bildirishnomalar${_unreadCount > 0 ? ' ($_unreadCount)' : ''}'),
            actions: [
              TextButton(
                onPressed: _markAllAsRead,
                child: const Text('Barchasini o‘qilgan',
                    style: TextStyle(color: Colors.white)),
              ),
              IconButton(
                  icon: const Icon(Icons.filter_list), onPressed: _showFilter),
            ],
            bottom: TabBar(
              controller: _tabController,
              onTap: _onTabChanged,
              tabs: const [
                Tab(text: 'Barchasi'),
                Tab(text: 'O‘qilmagan'),
                Tab(text: 'Muhim'),
              ],
            ),
          ),
          body: state is NotificationLoading && _notifications.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationsList(_filteredForTab('all')),
                    _buildNotificationsList(_filteredForTab('unread')),
                    _buildNotificationsList(_filteredForTab('important')),
                  ],
                ),
        );
      },
    );
  }

  void _onNotificationState(BuildContext context, NotificationState state) {
    if (state is NotificationsLoaded) {
      setState(() {
        _notifications = state.notifications;
        _unreadCount = state.unreadCount;
      });
    } else if (state is NotificationUnreadCountLoaded) {
      setState(() => _unreadCount = state.count);
    } else if (state is NotificationMarkedAsRead) {
      _loadCurrentTab();
    } else if (state is NotificationAllMarkedAsRead) {
      _loadCurrentTab();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barchasi o‘qilgan deb belgilandi')));
    } else if (state is NotificationDeleted) {
      _loadCurrentTab();
    } else if (state is NotificationNewReceived) {
      setState(() {
        _notifications = [state.notification, ..._notifications];
        _unreadCount = state.unreadCount;
      });
    } else if (state is NotificationError) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red));
    }
  }

  void _onTabChanged(int index) {
    _loadCurrentTab();
  }

  void _loadCurrentTab() {
    switch (_tabController.index) {
      case 1:
        _load(isRead: false, type: _typeFilter);
        break;
      case 2:
        _load(type: NotificationType.systemAlert);
        break;
      default:
        _load(type: _typeFilter);
    }
  }

  List<AppNotification> _filteredForTab(String tab) {
    Iterable<AppNotification> items = _notifications;
    if (_typeFilter != null)
      items = items.where((item) => item.type == _typeFilter);
    if (tab == 'unread') items = items.where((item) => !item.isRead);
    if (tab == 'important') {
      items = items.where((item) => {
            NotificationType.systemAlert,
            NotificationType.lowStock,
            NotificationType.highDebt,
            NotificationType.deliveryFailed,
            NotificationType.largeOrder,
          }.contains(item.type));
    }
    return items.toList();
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return _emptyState(
        icon: Icons.notifications_off,
        title: 'Bildirishnomalar yo‘q',
        message: 'Tanlangan filter bo‘yicha xabar topilmadi.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadCurrentTab(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) =>
            _buildNotificationCard(notifications[index]),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final isRead = notification.isRead;
    final color = _notificationColor(notification);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => context
          .read<NotificationBloc>()
          .add(NotificationDelete(notification.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color:
                  isRead ? Colors.grey.shade200 : color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: isRead ? 0.05 : 0.1),
                blurRadius: 8)
          ],
        ),
        child: InkWell(
          onTap: () => _openNotification(notification),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(_notificationIcon(notification.type),
                      color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                  fontWeight: isRead
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ),
                          if (!isRead)
                            Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: Color(0xFF1565C0),
                                    shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(notification.body,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(_relativeTime(notification.createdAt),
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 11)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(_typeLabel(notification.type),
                                style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _notificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderConfirmed:
      case NotificationType.orderCancelled:
      case NotificationType.largeOrder:
        return Icons.shopping_cart;
      case NotificationType.paymentReceived:
      case NotificationType.highDebt:
        return Icons.payment;
      case NotificationType.newTask:
        return Icons.assignment;
      case NotificationType.syncCompleted:
        return Icons.sync;
      case NotificationType.lowStock:
      case NotificationType.systemAlert:
      case NotificationType.systemError:
        return Icons.warning;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.newDelivery:
      case NotificationType.deliveryAssigned:
      case NotificationType.deliveryFailed:
      case NotificationType.routeChanged:
        return Icons.local_shipping;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.agentOffline:
        return Icons.person_off;
    }
  }

  Color _notificationColor(AppNotification notification) {
    switch (notification.type) {
      case NotificationType.orderConfirmed:
      case NotificationType.newDelivery:
      case NotificationType.deliveryAssigned:
      case NotificationType.syncCompleted:
        return const Color(0xFF2E7D32);
      case NotificationType.paymentReceived:
      case NotificationType.message:
        return const Color(0xFF1565C0);
      case NotificationType.newTask:
      case NotificationType.promotion:
        return const Color(0xFFFF6F00);
      case NotificationType.lowStock:
      case NotificationType.systemAlert:
      case NotificationType.systemError:
      case NotificationType.highDebt:
      case NotificationType.deliveryFailed:
      case NotificationType.orderCancelled:
      case NotificationType.agentOffline:
      case NotificationType.largeOrder:
        return const Color(0xFFC62828);
      case NotificationType.routeChanged:
        return const Color(0xFF00897B);
    }
  }

  String _typeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.orderConfirmed:
      case NotificationType.orderCancelled:
      case NotificationType.largeOrder:
        return 'Buyurtma';
      case NotificationType.paymentReceived:
        return 'To‘lov';
      case NotificationType.newTask:
        return 'Vazifa';
      case NotificationType.syncCompleted:
        return 'Sinxronlash';
      case NotificationType.lowStock:
      case NotificationType.systemAlert:
      case NotificationType.systemError:
      case NotificationType.highDebt:
        return 'Ogohlantirish';
      case NotificationType.promotion:
        return 'Aksiya';
      case NotificationType.newDelivery:
      case NotificationType.deliveryAssigned:
      case NotificationType.deliveryFailed:
      case NotificationType.routeChanged:
        return 'Yetkazish';
      case NotificationType.message:
        return 'Xabar';
      case NotificationType.agentOffline:
        return 'Agent';
    }
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }

  void _markAllAsRead() {
    context.read<NotificationBloc>().add(NotificationMarkAllAsRead());
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Filtrlash',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip('Barchasi', null),
                _filterChip('Buyurtmalar', NotificationType.orderConfirmed),
                _filterChip('To‘lovlar', NotificationType.paymentReceived),
                _filterChip('Vazifalar', NotificationType.newTask),
                _filterChip('Aksiyalar', NotificationType.promotion),
                _filterChip('Ogohlantirishlar', NotificationType.systemAlert),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, NotificationType? type) {
    return FilterChip(
      label: Text(label),
      selected: _typeFilter == type,
      onSelected: (_) {
        Navigator.pop(context);
        setState(() => _typeFilter = type);
        _loadCurrentTab();
      },
    );
  }

  void _openNotification(AppNotification notification) {
    context
        .read<NotificationBloc>()
        .add(NotificationMarkAsRead(notification.id));
    switch (notification.type) {
      case NotificationType.orderConfirmed:
      case NotificationType.orderCancelled:
      case NotificationType.largeOrder:
        context.push('/orders/history');
        break;
      case NotificationType.paymentReceived:
      case NotificationType.highDebt:
        context.push('/payments/collect');
        break;
      case NotificationType.newTask:
        context.push('/tasks');
        break;
      default:
        break;
    }
  }

  Widget _emptyState(
      {required IconData icon,
      required String title,
      required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(title,
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
