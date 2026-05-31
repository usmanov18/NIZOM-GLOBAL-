import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/competitor_entity.dart';
import '../../domain/repositories/competitor_repository.dart';

/// Raqobatchilar tahlili — CompetitorRepository orqali boshqariladi.
class CompetitorAnalysisScreen extends StatefulWidget {
  const CompetitorAnalysisScreen({super.key});

  @override
  State<CompetitorAnalysisScreen> createState() =>
      _CompetitorAnalysisScreenState();
}

class _CompetitorAnalysisScreenState extends State<CompetitorAnalysisScreen> {
  late Future<List<CompetitorEntity>> _future;

  CompetitorRepository get _repository => getIt<CompetitorRepository>();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<CompetitorEntity>> _load() async {
    final result = await _repository.getCompetitors();
    return result.fold(
        (failure) => throw Exception(failure.message), (items) => items);
  }

  void _reload() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CompetitorEntity>>(
      future: _future,
      builder: (context, snapshot) {
        final competitors = snapshot.data ?? const <CompetitorEntity>[];
        return Scaffold(
          appBar: AppBar(
            title: const Text('Raqobatchilar tahlili'),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
              IconButton(
                  icon: const Icon(Icons.add), onPressed: _addCompetitor),
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : snapshot.hasError
                  ? _emptyState(Icons.error_outline, 'Raqobatchilar yuklanmadi',
                      snapshot.error.toString())
                  : _buildContent(competitors),
        );
      },
    );
  }

  Widget _buildContent(List<CompetitorEntity> competitors) {
    if (competitors.isEmpty) {
      return _emptyState(Icons.analytics_outlined, 'Raqobatchilar topilmadi',
          'Raqobatchilar ma’lumotlari repository orqali yuklanadi.');
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMarketShareChart(competitors),
          const SizedBox(height: 20),
          _buildPriceComparison(competitors),
          const SizedBox(height: 20),
          _buildCompetitorList(competitors),
        ],
      ),
    );
  }

  Widget _buildMarketShareChart(List<CompetitorEntity> competitors) {
    final ourShare =
        (100 - competitors.fold<int>(0, (sum, item) => sum + item.marketShare))
            .clamp(0, 100);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bozor ulushi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...competitors.asMap().entries.map((entry) => _marketShareBar(
              entry.value.name, entry.value.marketShare, entry.key)),
          _marketShareBar('Bizning kompaniya', ourShare, -1),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
      ],
    );
  }

  Widget _marketShareBar(String name, int share, int index) {
    final colors = [
      const Color(0xFF1565C0),
      const Color(0xFF2E7D32),
      const Color(0xFFFF6F00),
      const Color(0xFF9C27B0),
    ];
    final color =
        index >= 0 ? colors[index % colors.length] : const Color(0xFFC62828);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(name, style: const TextStyle(fontSize: 13)),
            Text('$share%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: share / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceComparison(List<CompetitorEntity> competitors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Narx taqqoslash',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: const [
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Mahsulot',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12))),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Bizning',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12))),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Raqobatchilar',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12))),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Farq',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12))),
                ],
              ),
              ...competitors.map((competitor) => TableRow(children: [
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(competitor.name,
                            style: const TextStyle(fontSize: 13))),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(_formatPrice(competitor.ourPrice),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13))),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(_formatPrice(competitor.avgPrice),
                            style: const TextStyle(fontSize: 13))),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '${competitor.priceDifferencePercent > 0 ? '+' : ''}${competitor.priceDifferencePercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: competitor.priceDifferencePercent > 0
                              ? Colors.red
                              : const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitorList(List<CompetitorEntity> competitors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Raqobatchilar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...competitors.map(_buildCompetitorCard),
      ],
    );
  }

  Widget _buildCompetitorCard(CompetitorEntity competitor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
              child: Text(
                  competitor.name.isEmpty
                      ? '?'
                      : competitor.name.substring(0, 1),
                  style: const TextStyle(
                      color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(competitor.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    Text('Bozor ulushi: ${competitor.marketShare}%',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ]),
            ),
            Text('${_formatPrice(competitor.avgPrice)} so‘m',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1565C0))),
          ]),
          const SizedBox(height: 12),
          const Text('Kuchli tomonlari:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          Wrap(
            spacing: 6,
            children: competitor.strengths
                .map((item) => Chip(
                      label: Text(item, style: const TextStyle(fontSize: 11)),
                      backgroundColor:
                          const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          const Text('Kuchsiz tomonlari:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          Wrap(
            spacing: 6,
            children: competitor.weaknesses
                .map((item) => Chip(
                      label: Text(item, style: const TextStyle(fontSize: 11)),
                      backgroundColor:
                          const Color(0xFFC62828).withValues(alpha: 0.1),
                      labelStyle: const TextStyle(color: Color(0xFFC62828)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }

  void _addCompetitor() {
    final nameController = TextEditingController();
    final avgPriceController = TextEditingController();
    final ourPriceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raqobatchi qo‘shish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nomi')),
            TextField(
                controller: avgPriceController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Raqobatchi narxi')),
            TextField(
                controller: ourPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Bizning narx')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              final competitor = CompetitorEntity(
                id: 'competitor_${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                marketShare: 0,
                avgPrice: int.tryParse(avgPriceController.text) ?? 0,
                ourPrice: int.tryParse(ourPriceController.text) ?? 0,
                strengths: const [],
                weaknesses: const [],
              );
              final result = await _repository.addCompetitor(competitor);
              if (!mounted) return;
              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(failure.message),
                        backgroundColor: Colors.red)),
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Raqobatchi qo‘shildi')));
                  _reload();
                },
              );
            },
            child: const Text('Qo‘shish'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(IconData icon, String title, String message) {
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
          ],
        ),
      ),
    );
  }
}
