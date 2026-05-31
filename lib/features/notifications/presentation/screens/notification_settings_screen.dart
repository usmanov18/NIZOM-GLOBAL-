import 'package:flutter/material.dart';

/// Bildirishnoma sozlamalari
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _quietHoursEnabled = false;

  // Channel settings
  final Map<String, bool> _channels = {
    'Buyurtmalar': true,
    'To\'lovlar': true,
    'Yetkazish': true,
    'Vazifalar': true,
    'Aksiyalar': true,
    'Tizim': true,
    'Chat': true,
    'Sinxronlash': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirishnoma sozlamalari'),
      ),
      body: ListView(
        children: [
          // Umumiy
          _buildSection('Umumiy', [
            _buildSwitchTile(
              'Push bildirishnomalar',
              'Barcha push bildirishnomalar',
              Icons.notifications,
              _pushEnabled,
              (v) => setState(() => _pushEnabled = v),
            ),
            _buildSwitchTile(
              'Ovoz',
              'Bildirishnoma ovozi',
              Icons.volume_up,
              _soundEnabled,
              (v) => setState(() => _soundEnabled = v),
            ),
            _buildSwitchTile(
              'Vibratsiya',
              'Bildirishnoma vibratsiyasi',
              Icons.vibration,
              _vibrationEnabled,
              (v) => setState(() => _vibrationEnabled = v),
            ),
          ]),

          // Kanallar
          _buildSection(
            'Bildirishnoma turlari',
            _channels.entries.map((entry) {
              return _buildSwitchTile(
                entry.key,
                _getChannelDescription(entry.key),
                _getChannelIcon(entry.key),
                entry.value,
                (v) => setState(() => _channels[entry.key] = v),
              );
            }).toList(),
          ),

          // Jimjit vaqt
          _buildSection('Jimjit vaqt', [
            _buildSwitchTile(
              'Jimjit vaqt',
              '22:00 - 07:00 oralig\'ida bildirishnomalar o\'chiriladi',
              Icons.do_not_disturb,
              _quietHoursEnabled,
              (v) => setState(() => _quietHoursEnabled = v),
            ),
            if (_quietHoursEnabled) ...[
              _buildTimeTile('Boshlanish', '22:00'),
              _buildTimeTile('Tugash', '07:00'),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF1565C0)),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF1565C0),
    );
  }

  Widget _buildTimeTile(String label, String time) {
    return ListTile(
      title: Text(label),
      trailing: Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () => _showTimePickerInfo(label),
    );
  }

  String _getChannelDescription(String channel) {
    switch (channel) {
      case 'Buyurtmalar':
        return 'Yangi buyurtma, tasdiqlash, bekor qilish';
      case 'To\'lovlar':
        return 'To\'lov qabul qilindi, muddati o\'tdi';
      case 'Yetkazish':
        return 'Yangi yetkazish, holat o\'zgarishi';
      case 'Vazifalar':
        return 'Yangi vazifa, eslatma';
      case 'Aksiyalar':
        return 'Chegirmalar, promolar';
      case 'Tizim':
        return 'Tizim xabarlari, yangilanishlar';
      case 'Chat':
        return 'Yangi xabarlar';
      case 'Sinxronlash':
        return '1C/SAP sinxronlash natijalari';
      default:
        return '';
    }
  }

  IconData _getChannelIcon(String channel) {
    switch (channel) {
      case 'Buyurtmalar':
        return Icons.shopping_cart;
      case 'To\'lovlar':
        return Icons.payment;
      case 'Yetkazish':
        return Icons.local_shipping;
      case 'Vazifalar':
        return Icons.assignment;
      case 'Aksiyalar':
        return Icons.local_offer;
      case 'Tizim':
        return Icons.settings;
      case 'Chat':
        return Icons.chat;
      case 'Sinxronlash':
        return Icons.sync;
      default:
        return Icons.notifications;
    }
  }

  void _showTimePickerInfo(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label vaqtini tanlash oynasi ochildi')),
    );
  }
}
