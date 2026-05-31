import 'package:flutter/material.dart';

/// Custom Report Builder - Maxsus hisobot yaratish
class ReportBuilderScreen extends StatefulWidget {
  const ReportBuilderScreen({super.key});

  @override
  State<ReportBuilderScreen> createState() => _ReportBuilderScreenState();
}

class _ReportBuilderScreenState extends State<ReportBuilderScreen> {
  String _selectedReportType = 'sales';
  String _selectedPeriod = 'month';
  String? _selectedAgent;
  String? _selectedRegion;
  String _exportFormat = 'pdf';

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'id': 'sales',
      'name': 'Savdo hisoboti',
      'icon': Icons.trending_up,
      'color': Color(0xFF2E7D32)
    },
    {
      'id': 'customers',
      'name': 'Mijozlar hisoboti',
      'icon': Icons.people,
      'color': Color(0xFF1565C0)
    },
    {
      'id': 'products',
      'name': 'Mahsulotlar hisoboti',
      'icon': Icons.inventory_2,
      'color': Color(0xFFFF6F00)
    },
    {
      'id': 'agents',
      'name': 'Agentlar hisoboti',
      'icon': Icons.person,
      'color': Color(0xFF00897B)
    },
    {
      'id': 'payments',
      'name': 'To\'lovlar hisoboti',
      'icon': Icons.payment,
      'color': Color(0xFF9C27B0)
    },
    {
      'id': 'delivery',
      'name': 'Yetkazish hisoboti',
      'icon': Icons.local_shipping,
      'color': Color(0xFF795548)
    },
    {
      'id': 'inventory',
      'name': 'Ombor hisoboti',
      'icon': Icons.warehouse,
      'color': Color(0xFF607D8B)
    },
    {
      'id': 'financial',
      'name': 'Moliyaviy hisobot',
      'icon': Icons.account_balance,
      'color': Color(0xFFC62828)
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hisobot yaratish'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTemplate),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report type
            _buildSection('Hisobot turi', _buildReportTypeSelector()),
            const SizedBox(height: 20),

            // Period
            _buildSection('Davr', _buildPeriodSelector()),
            const SizedBox(height: 20),

            // Filters
            _buildSection('Filtrlash', _buildFilters()),
            const SizedBox(height: 20),

            // Export format
            _buildSection('Export formati', _buildExportFormat()),
            const SizedBox(height: 24),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _generateReport,
                icon: const Icon(Icons.assessment),
                label: const Text('Hisobot yaratish',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildReportTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _reportTypes.map((type) {
        final isSelected = _selectedReportType == type['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedReportType = type['id']),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (type['color'] as Color).withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected ? type['color'] as Color : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(type['icon'], size: 16, color: type['color'] as Color),
                const SizedBox(width: 6),
                Text(type['name'],
                    style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? type['color'] as Color
                            : Colors.grey.shade700)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _periodChip('Bugun', 'today'),
        const SizedBox(width: 8),
        _periodChip('Hafta', 'week'),
        const SizedBox(width: 8),
        _periodChip('Oy', 'month'),
        const SizedBox(width: 8),
        _periodChip('Yil', 'year'),
        const SizedBox(width: 8),
        _periodChip('Maxsus', 'custom'),
      ],
    );
  }

  Widget _periodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  isSelected ? const Color(0xFF1565C0) : Colors.grey.shade300),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 13)),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Agent',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Barchasi')),
            DropdownMenuItem(value: 'agent_1', child: Text('Karimov Alisher')),
            DropdownMenuItem(value: 'agent_2', child: Text('Toshmatov Jasur')),
          ],
          onChanged: (v) => setState(() => _selectedAgent = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Hudud',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Barchasi')),
            DropdownMenuItem(value: 'tashkent', child: Text('Toshkent')),
            DropdownMenuItem(value: 'samarkand', child: Text('Samarqand')),
          ],
          onChanged: (v) => setState(() => _selectedRegion = v),
        ),
      ],
    );
  }

  Widget _buildExportFormat() {
    return Row(
      children: [
        _formatChip(
            'PDF', 'pdf', Icons.picture_as_pdf, const Color(0xFFC62828)),
        const SizedBox(width: 8),
        _formatChip(
            'Excel', 'excel', Icons.table_chart, const Color(0xFF2E7D32)),
        const SizedBox(width: 8),
        _formatChip('CSV', 'csv', Icons.description, const Color(0xFF1565C0)),
      ],
    );
  }

  Widget _formatChip(String label, String value, IconData icon, Color color) {
    final isSelected = _exportFormat == value;
    return GestureDetector(
      onTap: () => setState(() => _exportFormat = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: isSelected ? color : Colors.grey.shade700,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _saveTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Shablon saqlandi'),
          backgroundColor: Color(0xFF2E7D32)),
    );
  }

  void _generateReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hisobot yaratilmoqda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('$_exportFormat formatida hisobot generatsiya qilinmoqda...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hisobot $_exportFormat formatida yaratildi!'),
          backgroundColor: const Color(0xFF2E7D32),
          action: SnackBarAction(
              label: 'Ko\'rish',
              textColor: Colors.white,
              onPressed: _showReportReady),
        ),
      );
    });
  }

  void _showReportReady() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hisobot preview oynasi ochildi')),
    );
  }
}
