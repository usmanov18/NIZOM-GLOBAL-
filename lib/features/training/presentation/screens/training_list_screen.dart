import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/training_course.dart';
import '../../domain/repositories/training_repository.dart';

/// O'qitish moduli — TrainingRepository orqali boshqariladi.
class TrainingListScreen extends StatefulWidget {
  const TrainingListScreen({super.key});

  @override
  State<TrainingListScreen> createState() => _TrainingListScreenState();
}

class _TrainingListScreenState extends State<TrainingListScreen> {
  late Future<List<TrainingCourse>> _future;

  TrainingRepository get _repository => getIt<TrainingRepository>();

  @override
  void initState() {
    super.initState();
    _future = _repository.getCourses().then((result) => result.fold(
        (failure) => throw Exception(failure.message), (items) => items));
  }

  void _reload() {
    setState(() {
      _future = _repository.getCourses().then((result) => result.fold(
          (failure) => throw Exception(failure.message), (items) => items));
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TrainingCourse>>(
      future: _future,
      builder: (context, snapshot) {
        final courses = snapshot.data ?? const <TrainingCourse>[];
        return Scaffold(
          appBar: AppBar(
            title: const Text('O‘qitish'),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _reload)
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : snapshot.hasError
                  ? _emptyState(Icons.error_outline, 'Kurslar yuklanmadi',
                      snapshot.error.toString())
                  : _buildContent(courses),
        );
      },
    );
  }

  Widget _buildContent(List<TrainingCourse> courses) {
    if (courses.isEmpty) {
      return _emptyState(Icons.school_outlined, 'Kurslar topilmadi',
          'O‘quv kurslari repository orqali yuklanadi.');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStats(courses),
          const SizedBox(height: 20),
          const Text('Kurslar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...courses.map(_buildCourseCard),
        ],
      ),
    );
  }

  Widget _buildStats(List<TrainingCourse> courses) {
    final completed = courses.where((course) => course.isCompleted).length;
    final inProgress = courses.where((course) => course.isInProgress).length;
    final certificates =
        courses.where((course) => course.hasCertificate).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Kurslar', '${courses.length}', Icons.school),
          _stat('Tugallangan', '$completed', Icons.check_circle),
          _stat('Jarayonda', '$inProgress', Icons.pending),
          _stat('Sertifikatlar', '$certificates', Icons.card_membership),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Column(children: [
      Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 22),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
    ]);
  }

  Widget _buildCourseCard(TrainingCourse course) {
    final color = _courseColor(course);
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
        onTap: () => _openCourse(course),
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
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.school, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(course.description,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _infoChip(
                      Icons.access_time, _formatDuration(course.duration)),
                  const SizedBox(width: 8),
                  _infoChip(Icons.menu_book, '${course.lessons} dars'),
                  const Spacer(),
                  Text('${(course.progress * 100).toInt()}%',
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: course.progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.grey.shade500),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
    ]);
  }

  Color _courseColor(TrainingCourse course) {
    switch (course.status) {
      case TrainingCourseStatus.completed:
        return const Color(0xFF2E7D32);
      case TrainingCourseStatus.inProgress:
        return const Color(0xFF1565C0);
      case TrainingCourseStatus.notStarted:
        return const Color(0xFFC62828);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) return '${duration.inMinutes} daq';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return minutes == 0 ? '$hours soat' : '$hours soat $minutes daq';
  }

  Future<void> _openCourse(TrainingCourse course) async {
    final nextProgress =
        course.progress >= 1 ? 1.0 : (course.progress + 0.1).clamp(0.0, 1.0);
    final result =
        await _repository.updateProgress(id: course.id, progress: nextProgress);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(failure.message), backgroundColor: Colors.red)),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${course.title} kursi ochildi')));
        _reload();
      },
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
