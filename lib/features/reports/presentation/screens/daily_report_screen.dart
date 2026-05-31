import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/repositories/report_repository.dart';

/// Kunlik hisobot — ReportRepository orqali real API/cache'dan yuklanadi.
class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  DateTime _selectedDate = DateTime.now();
  late Future<DailyReport> _future;

  ReportRepository get _repository => getIt<ReportRepository>();

  @override
  void initState() {
    super.initState();
    _future = _loadReport();
  }

  Future<String> _currentAgentId() async {
    final result = await getIt<AuthRepository>().getCurrentUser();
    final user = result.fold((_) => null, (value) => value);
    return user?.id ?? user?.code ?? 'current';
  }

  Future<DailyReport> _loadReport() async {
    final agentId = await _currentAgentId();
    final result =
        await _repository.getDailyReport(agentId: agentId, date: _selectedDate);
    return result.fold(
        (failure) => throw Exception(failure.message), (report) => report);
  }

  void _reload() {
    setState(() => _future = _loadReport());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DailyReport>(
      future: _future,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kunlik hisobot'),
            actions: [
              IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _selectDate),
              IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareReport(snapshot.data)),
              IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () => _printReport(snapshot.data)),
            ],
          ),
          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<DailyReport> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError || !snapshot.hasData) {
      return _emptyState(
        icon: Icons.assessment_outlined,
        title: 'Kunlik hisobot yuklanmadi',
        message:
            snapshot.error?.toString() ?? 'Hisobot ma’lumotlari topilmadi.',
        action: ElevatedButton.icon(
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
          label: const Text('Qayta yuklash'),
        ),
      );
    }

    final report = snapshot.data!;
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(report),
            const SizedBox(height: 20),
            _buildSalesStats(report),
            const SizedBox(height: 16),
            _buildPaymentStats(report),
            const SizedBox(height: 16),
            _buildVisitStats(report),
            const SizedBox(height: 16),
            _buildWorkTimeStats(report),
            const SizedBox(height: 16),
            _buildTopProducts(report),
            const SizedBox(height: 16),
            _buildTopCustomers(report),
            const SizedBox(height: 24),
            _buildExportButtons(report),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DailyReport report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1565C0).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatDate(report.date),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                      report.agentName.isEmpty
                          ? report.agentId
                          : report.agentName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(report.agentId,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(_formatDuration(report.workHours),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _headerStat(
                  'Buyurtmalar', '${report.totalOrders}', Icons.shopping_cart),
              _headerStat(
                  'Sotuv',
                  '${(report.totalSales / 1000000).toStringAsFixed(1)}M',
                  Icons.attach_money),
              _headerStat(
                  'Tashriflar', '${report.totalVisits}', Icons.location_on),
              _headerStat('Masofa',
                  '${report.totalDistance.toStringAsFixed(1)}km', Icons.route),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
      ],
    );
  }

  Widget _buildSalesStats(DailyReport report) {
    final avg =
        report.totalOrders == 0 ? 0 : report.totalSales / report.totalOrders;
    return _buildSection('Sotuv statistikasi', Icons.trending_up, [
      _statRow('Buyurtmalar soni', '${report.totalOrders} ta'),
      _statRow('Jami sotuv', '${_formatAmount(report.totalSales)} so‘m'),
      _statRow('O‘rtacha buyurtma', '${_formatAmount(avg)} so‘m'),
    ]);
  }

  Widget _buildPaymentStats(DailyReport report) {
    return _buildSection('To‘lovlar', Icons.payment, [
      _statRow(
          'Jami yig‘ilgan', '${_formatAmount(report.totalCollections)} so‘m'),
      _statRow(
          'Yig‘im / sotuv',
          report.totalSales == 0
              ? '0%'
              : '${(report.totalCollections / report.totalSales * 100).toStringAsFixed(0)}%'),
    ]);
  }

  Widget _buildVisitStats(DailyReport report) {
    final completionRate = report.totalVisits == 0
        ? '0'
        : (report.completedVisits / report.totalVisits * 100)
            .toStringAsFixed(0);
    return _buildSection('Tashriflar', Icons.location_on, [
      _statRow('Jami tashriflar', '${report.totalVisits} ta'),
      _statRow('Bajarildi', '${report.completedVisits} ta'),
      _statRow('Bajarilish darajasi', '$completionRate%'),
    ]);
  }

  Widget _buildWorkTimeStats(DailyReport report) {
    return _buildSection('Ish vaqti', Icons.access_time, [
      _statRow('Jami ish vaqti', _formatDuration(report.workHours)),
      _statRow(
          'Umumiy masofa', '${report.totalDistance.toStringAsFixed(1)} km'),
    ]);
  }

  Widget _buildTopProducts(DailyReport report) {
    final items = report.topProducts.map((item) {
      final name = (item['name'] ?? item['productName'] ?? '-').toString();
      final quantity = item['quantity'] ?? item['qty'] ?? 0;
      final amount = (item['amount'] ?? item['revenue'] ?? 0) as num;
      return _rankedItem(
          name, '$quantity dona', '${_formatAmount(amount)} so‘m');
    }).toList();
    return _buildSection('Top mahsulotlar', Icons.star,
        items.isEmpty ? [const Text('Mahsulotlar statistikasi yo‘q')] : items);
  }

  Widget _buildTopCustomers(DailyReport report) {
    final items = report.topCustomers.map((item) {
      final name = (item['name'] ?? item['customerName'] ?? '-').toString();
      final orders = item['orders'] ?? item['totalOrders'] ?? 0;
      final amount = (item['amount'] ?? item['totalSales'] ?? 0) as num;
      return _rankedItem(
          name, '$orders buyurtma', '${_formatAmount(amount)} so‘m');
    }).toList();
    return _buildSection('Top mijozlar', Icons.people,
        items.isEmpty ? [const Text('Mijozlar statistikasi yo‘q')] : items);
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
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
          Row(children: [
            Icon(icon, color: const Color(0xFF1565C0), size: 20),
            const SizedBox(width: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          Flexible(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _rankedItem(String name, String subtitle, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
                Text(subtitle,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF2E7D32))),
        ],
      ),
    );
  }

  Widget _buildExportButtons(DailyReport report) {
    return Row(
      children: [
        Expanded(
            child: _exportButton(
                'PDF',
                Icons.picture_as_pdf,
                const Color(0xFFC62828),
                () => _exportReport(ReportFormat.pdf))),
        const SizedBox(width: 12),
        Expanded(
            child: _exportButton(
                'Excel',
                Icons.table_chart,
                const Color(0xFF2E7D32),
                () => _exportReport(ReportFormat.excel))),
        const SizedBox(width: 12),
        Expanded(
            child: _exportButton('Ulashish', Icons.share,
                const Color(0xFF1565C0), () => _shareReport(report))),
      ],
    );
  }

  Widget _exportButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14)),
    );
  }

  String _formatAmount(num amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '$minutes daq';
    return '$hours soat $minutes daq';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _future = _loadReport();
      });
    }
  }

  Future<void> _exportReport(ReportFormat format) async {
    final agentId = await _currentAgentId();
    final result = await _repository.exportReport(
      type: ReportType.sales,
      format: format,
      fromDate: _selectedDate,
      toDate: _selectedDate,
      agentId: agentId,
    );
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(failure.message), backgroundColor: Colors.red)),
      (path) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hisobot export qilindi: $path'))),
    );
  }

  void _shareReport(DailyReport? report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(report == null
              ? 'Hisobot hali yuklanmagan'
              : '${_formatDate(report.date)} hisobot ulashildi')),
    );
  }

  void _printReport(DailyReport? report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(report == null
              ? 'Hisobot hali yuklanmagan'
              : '${_formatDate(report.date)} hisobot chop etilmoqda')),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade500),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
