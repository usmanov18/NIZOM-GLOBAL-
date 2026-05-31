import 'package:flutter/material.dart';

/// Tashriflar rejalashtirish - Haftalik rejalar
class VisitPlanningScreen extends StatefulWidget {
  const VisitPlanningScreen({super.key});

  @override
  State<VisitPlanningScreen> createState() => _VisitPlanningScreenState();
}

class _VisitPlanningScreenState extends State<VisitPlanningScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedDayIndex = 0;

  final List<Map<String, dynamic>> _weekDays = [
    {'day': 'Du', 'date': 25, 'visits': 8, 'completed': 5},
    {'day': 'Se', 'date': 26, 'visits': 10, 'completed': 3},
    {'day': 'Ch', 'date': 27, 'visits': 6, 'completed': 0},
    {'day': 'Pa', 'date': 28, 'visits': 8, 'completed': 0},
    {'day': 'Ju', 'date': 29, 'visits': 5, 'completed': 0},
    {'day': 'Sh', 'date': 30, 'visits': 4, 'completed': 0},
    {'day': 'Ya', 'date': 31, 'visits': 0, 'completed': 0},
  ];

  final List<Map<String, dynamic>> _todayVisits = [
    {
      'id': '1',
      'customer': 'Super Market "Barka"',
      'address': 'Toshkent, Chilonzor 12',
      'time': '09:00',
      'status': 'completed',
      'type': 'savdo',
      'orderAmount': 5600000,
      'notes': 'Yangi buyurtma olindi',
    },
    {
      'id': '2',
      'customer': 'Do\'kon "Yangi hayot"',
      'address': 'Toshkent, Yunusobod 7',
      'time': '10:30',
      'status': 'completed',
      'type': 'savdo',
      'orderAmount': 3200000,
      'notes': 'To\'lov qabul qilindi',
    },
    {
      'id': '3',
      'customer': 'Mini Market "Farhod"',
      'address': 'Toshkent, Sergeli 3',
      'time': '13:00',
      'status': 'in_progress',
      'type': 'savdo',
      'orderAmount': 0,
      'notes': '',
    },
    {
      'id': '4',
      'customer': 'Market "O\'zbekiston"',
      'address': 'Toshkent, Mirzo Ulug\'bek 15',
      'time': '14:30',
      'status': 'planned',
      'type': 'savdo',
      'orderAmount': 0,
      'notes': '',
    },
    {
      'id': '5',
      'customer': 'Do\'kon "Cho\'pon ota"',
      'address': 'Toshkent, Olmazor 22',
      'time': '16:00',
      'status': 'planned',
      'type': 'tashrif',
      'orderAmount': 0,
      'notes': 'Yangi mahsulotlar taqdimoti',
    },
    {
      'id': '6',
      'customer': 'Super Market "Alisher"',
      'address': 'Toshkent, Beruniy 8',
      'time': '17:00',
      'status': 'planned',
      'type': 'savdo',
      'orderAmount': 0,
      'notes': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tashriflar rejasI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectDate,
          ),
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: _addVisit,
          ),
        ],
      ),
      body: Column(
        children: [
          // Week calendar
          _buildWeekCalendar(),

          // Stats
          _buildDayStats(),

          // Visits list
          Expanded(child: _buildVisitsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addVisit,
        icon: const Icon(Icons.add),
        label: const Text('Tashrif qo\'shish'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  Widget _buildWeekCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _weekDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isSelected = index == _selectedDayIndex;
          final isToday = index == 1; // Bugun

          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF1565C0) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    day['day'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day['date']}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (day['visits'] > 0)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.white : const Color(0xFF1565C0),
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 6),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayStats() {
    final completed =
        _todayVisits.where((v) => v['status'] == 'completed').length;
    final total = _todayVisits.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1565C0).withValues(alpha: 0.05),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              Text('$completed/$total tashrif',
                  style: const TextStyle(
                      color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _dayStat('Sotuv',
                  '${_todayVisits.where((v) => v['orderAmount'] > 0).fold(0, (sum, v) => sum + (v['orderAmount'] as int)) ~/ 1000000}M'),
              _dayStat('To\'lovlar', '8M'),
              _dayStat('Masofa', '12 km'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      ],
    );
  }

  Widget _buildVisitsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _todayVisits.length,
      itemBuilder: (context, index) => _buildVisitCard(_todayVisits[index]),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (visit['status']) {
      case 'completed':
        statusColor = const Color(0xFF2E7D32);
        statusText = 'Bajarildi';
        statusIcon = Icons.check_circle;
        break;
      case 'in_progress':
        statusColor = const Color(0xFFFF6F00);
        statusText = 'Jarayonda';
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = const Color(0xFF1565C0);
        statusText = 'Rejalangan';
        statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: InkWell(
        onTap: () => _showVisitDetails(visit),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Time
              Container(
                width: 55,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(visit['time'],
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Icon(statusIcon, color: statusColor, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visit['customer'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(visit['address'],
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    if (visit['type'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: visit['type'] == 'savdo'
                                ? const Color(0xFF1565C0).withValues(alpha: 0.1)
                                : const Color(0xFFFF6F00)
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            visit['type'] == 'savdo' ? 'Savdo' : 'Tashrif',
                            style: TextStyle(
                              color: visit['type'] == 'savdo'
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFFFF6F00),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (visit['notes'] != null && visit['notes'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(visit['notes'],
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontStyle: FontStyle.italic)),
                      ),
                  ],
                ),
              ),

              // Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  if (visit['orderAmount'] > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                          '${(visit['orderAmount'] / 1000000).toStringAsFixed(1)}M',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(0xFF2E7D32))),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVisitDetails(Map<String, dynamic> visit) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(visit['customer'],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _detailItem(Icons.location_on, visit['address']),
              _detailItem(Icons.access_time, visit['time']),
              _detailItem(
                  Icons.category,
                  visit['type'] == 'savdo'
                      ? 'Savdo tashrifi'
                      : 'Oddiy tashrif'),
              if (visit['notes'] != null && visit['notes'].isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Izohlar',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(visit['notes']),
              ],
              const SizedBox(height: 24),
              if (visit['status'] != 'completed')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Tashrifni yakunlash'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey.shade700))),
      ]),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _addVisit() {
    // Tashrif qo'shish
  }
}
