import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task_bloc.dart';

/// Vazifalar boshqaruvi — TaskBloc orqali boshqariladi.
class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<TaskBloc>().add(TasksLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: _onTaskState,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Vazifalar'),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
              IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterInfo),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Barchasi'),
                Tab(text: 'Kutilmoqda'),
                Tab(text: 'Jarayonda'),
                Tab(text: 'Tugallangan'),
              ],
            ),
          ),
          body: state is TaskLoading && _tasks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList('all'),
                    _buildTaskList('pending'),
                    _buildTaskList('in_progress'),
                    _buildTaskList('completed'),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _createTask,
            icon: const Icon(Icons.add),
            label: const Text('Vazifa yaratish'),
            backgroundColor: const Color(0xFF1565C0),
          ),
        );
      },
    );
  }

  void _onTaskState(BuildContext context, TaskState state) {
    if (state is TasksLoaded) {
      setState(() => _tasks = state.tasks);
    } else if (state is TaskCreated) {
      setState(() => _tasks = [state.task, ..._tasks]);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Vazifa yaratildi')));
    } else if (state is TaskUpdated || state is TaskDeleted) {
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vazifa holati yangilandi')));
    } else if (state is TaskError) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red));
    }
  }

  void _reload() {
    context.read<TaskBloc>().add(TasksLoadRequested());
  }

  Widget _buildTaskList(String filter) {
    final filtered = filter == 'all'
        ? _tasks
        : _tasks.where((task) => task['status'] == filter).toList();

    if (filtered.isEmpty) {
      return _emptyState(
        icon: Icons.assignment_turned_in,
        title: 'Vazifalar yo‘q',
        message: 'Tanlangan status bo‘yicha vazifa topilmadi.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildTaskCard(filtered[index]),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final priority = (task['priority'] ?? 'low').toString();
    final type = (task['type'] ?? 'other').toString();
    final status = (task['status'] ?? 'pending').toString();
    final priorityColor = switch (priority) {
      'high' => const Color(0xFFC62828),
      'medium' => const Color(0xFFFF6F00),
      _ => const Color(0xFF1565C0),
    };
    final typeIcon = switch (type) {
      'visit' => Icons.location_on,
      'collection' => Icons.payment,
      'inventory' => Icons.inventory_2,
      'order' => Icons.shopping_cart,
      _ => Icons.assignment,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 5)
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(typeIcon, color: priorityColor, size: 22),
        ),
        title: Text(task['title']?.toString() ?? '-',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task['description']?.toString() ?? '',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _miniInfo(Icons.access_time,
                    _formatDueDate(task['due_date'] ?? task['dueDate'])),
                if (task['customer'] != null || task['customer_name'] != null)
                  _miniInfo(Icons.store,
                      (task['customer'] ?? task['customer_name']).toString()),
                _miniInfo(Icons.flag, _statusLabel(status)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTaskAction(value, task),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'complete', child: Text('Tugallangan')),
            PopupMenuItem(value: 'start', child: Text('Boshlash')),
            PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
            PopupMenuItem(
                value: 'delete',
                child: Text('O‘chirish', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      ],
    );
  }

  String _formatDueDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return value?.toString() ?? '-';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Kutilmoqda';
      case 'in_progress':
        return 'Jarayonda';
      case 'completed':
        return 'Tugallangan';
      default:
        return status;
    }
  }

  void _handleTaskAction(String action, Map<String, dynamic> task) {
    final id = task['id']?.toString() ?? '';
    switch (action) {
      case 'complete':
        context
            .read<TaskBloc>()
            .add(TaskUpdateRequested(taskId: id, status: 'completed'));
        break;
      case 'start':
        context
            .read<TaskBloc>()
            .add(TaskUpdateRequested(taskId: id, status: 'in_progress'));
        break;
      case 'delete':
        context.read<TaskBloc>().add(TaskDeleteRequested(id));
        break;
      case 'edit':
        _showTaskEditor(existing: task);
        break;
    }
  }

  void _createTask() => _showTaskEditor();

  void _showTaskEditor({Map<String, dynamic>? existing}) {
    final titleController =
        TextEditingController(text: existing?['title']?.toString() ?? '');
    final descriptionController =
        TextEditingController(text: existing?['description']?.toString() ?? '');
    String type = existing?['type']?.toString() ?? 'visit';
    String priority = existing?['priority']?.toString() ?? 'medium';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title:
            Text(existing == null ? 'Vazifa yaratish' : 'Vazifani tahrirlash'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Nomi')),
              TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Tavsif')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Turi'),
                items: const [
                  DropdownMenuItem(value: 'visit', child: Text('Tashrif')),
                  DropdownMenuItem(value: 'order', child: Text('Buyurtma')),
                  DropdownMenuItem(value: 'collection', child: Text('To‘lov')),
                  DropdownMenuItem(value: 'other', child: Text('Boshqa')),
                ],
                onChanged: (value) => type = value ?? type,
              ),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: const InputDecoration(labelText: 'Muhimlik'),
                items: const [
                  DropdownMenuItem(value: 'high', child: Text('Yuqori')),
                  DropdownMenuItem(value: 'medium', child: Text('O‘rta')),
                  DropdownMenuItem(value: 'low', child: Text('Past')),
                ],
                onChanged: (value) => priority = value ?? priority,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Bekor')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) return;
              Navigator.pop(dialogContext);
              if (existing == null) {
                context.read<TaskBloc>().add(TaskCreateRequested(
                      title: title,
                      description: descriptionController.text.trim(),
                      type: type,
                      priority: priority,
                      assigneeId: 'agent_1',
                      dueDate: DateTime.now().add(const Duration(days: 1)),
                    ));
              } else {
                context.read<TaskBloc>().add(TaskUpdateRequested(
                    taskId: existing['id'].toString(),
                    result: descriptionController.text.trim()));
              }
            },
            child: Text(existing == null ? 'Yaratish' : 'Saqlash'),
          ),
        ],
      ),
    );
  }

  void _showFilterInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Vazifalar tablar orqali status bo‘yicha filterlanadi')),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
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
          ],
        ),
      ),
    );
  }
}
