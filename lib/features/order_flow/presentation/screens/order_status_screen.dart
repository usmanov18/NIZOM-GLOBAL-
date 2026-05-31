import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/order_flow_bloc.dart';
import '../../domain/entities/order_flow_entities.dart';

/// 5-BOSQICH: Buyurtma holati - 1C/SAP sinxronlash natijasi
class OrderStatusScreen extends StatefulWidget {
  final Order order;
  
  const OrderStatusScreen({super.key, required this.order});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  
  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    
    // Buyurtma yuborish
    context.read<OrderFlowBloc>().add(SubmitOrder(widget.order.id));
  }
  
  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyurtma holati'),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<OrderFlowBloc, OrderFlowState>(
        listener: (context, state) {
          if (state is OrderSubmittedSuccess) {
            _checkController.forward();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Status animation
                _buildStatusAnimation(state),
                const SizedBox(height: 32),
                
                // Order info
                _buildOrderInfo(),
                const SizedBox(height: 24),
                
                // Sync status
                _buildSyncStatus(state),
                const SizedBox(height: 24),
                
                // 1C Status
                _buildSystemStatus(
                  '1C:Enterprise',
                  state is OrderSubmittedSuccess ? state.syncedTo1C : false,
                  state is OrderSubmitting,
                ),
                const SizedBox(height: 12),
                
                // SAP Status
                _buildSystemStatus(
                  'SAP S/4HANA',
                  state is OrderSubmittedSuccess ? state.syncedToSAP : false,
                  state is OrderSubmitting,
                ),
                const SizedBox(height: 32),
                
                // Actions
                _buildActions(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusAnimation(OrderFlowState state) {
    if (state is OrderFlowLoading || state is OrderSubmitting) {
      return Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF1565C0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            state is OrderSubmitting
                ? 'Serverga yuborilmoqda...'
                : 'Buyurtma yaratilmoqda...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    
    if (state is OrderSubmittedSuccess) {
      return ScaleTransition(
        scale: _checkAnimation,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: state.syncedTo1C || state.syncedToSAP
                ? const Color(0xFF2E7D32).withOpacity(0.1)
                : const Color(0xFFFF6F00).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            state.syncedTo1C || state.syncedToSAP
                ? Icons.check_circle
                : Icons.warning,
            size: 80,
            color: state.syncedTo1C || state.syncedToSAP
                ? const Color(0xFF2E7D32)
                : const Color(0xFFFF6F00),
          ),
        ),
      );
    }
    
    if (state is OrderFlowError) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error,
          size: 80,
          color: Colors.red,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Buyurtma #${widget.order.orderNumber}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.order.customerName,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_formatAmount(widget.order.totalAmount)} so\'m',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.order.totalItems} ta mahsulot',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus(OrderFlowState state) {
    String statusText;
    Color statusColor;
    IconData statusIcon;
    
    if (state is OrderSubmittedSuccess) {
      if (state.syncedTo1C && state.syncedToSAP) {
        statusText = 'Muvaffaqiyatli yuborildi!';
        statusColor = const Color(0xFF2E7D32);
        statusIcon = Icons.check_circle;
      } else if (state.syncedTo1C || state.syncedToSAP) {
        statusText = 'Qisman yuborildi';
        statusColor = const Color(0xFFFF6F00);
        statusIcon = Icons.warning;
      } else {
        statusText = 'Yuborishda xatolik';
        statusColor = Colors.red;
        statusIcon = Icons.error;
      }
    } else if (state is OrderFlowError) {
      statusText = 'Xatolik: ${state.message}';
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else {
      statusText = 'Yuborilmoqda...';
      statusColor = const Color(0xFF1565C0);
      statusIcon = Icons.sync;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus(String system, bool synced, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: synced
                  ? const Color(0xFF2E7D32).withOpacity(0.1)
                  : isLoading
                      ? const Color(0xFF1565C0).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      synced ? Icons.check : Icons.sync_problem,
                      color: synced
                          ? const Color(0xFF2E7D32)
                          : Colors.grey,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  system,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  synced ? 'Sinxronlashtirildi' : 'Sinxronlanmagan',
                  style: TextStyle(
                    color: synced
                        ? const Color(0xFF2E7D32)
                        : Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          
          // Status icon
          Icon(
            synced ? Icons.check_circle : Icons.radio_button_unchecked,
            color: synced ? const Color(0xFF2E7D32) : Colors.grey.shade400,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, OrderFlowState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state is OrderSubmittedSuccess && 
            (!state.syncedTo1C || !state.syncedToSAP))
          OutlinedButton.icon(
            onPressed: () {
              context.read<OrderFlowBloc>().add(
                SyncAllPending(),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Qayta urinish'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        const SizedBox(height: 12),
        
        ElevatedButton.icon(
          onPressed: () {
            // Yangi buyurtma
            context.read<OrderFlowBloc>().add(ResetOrderForm());
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          icon: const Icon(Icons.add),
          label: const Text('Yangi buyurtma'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        
        OutlinedButton.icon(
          onPressed: () {
            // Buyurtmalar ro'yxatiga o'tish
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          icon: const Icon(Icons.list),
          label: const Text('Buyurtmalar ro\'yxati'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}
