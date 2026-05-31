import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/conflict_bloc.dart';

class ConflictResolutionScreen extends StatelessWidget {
  const ConflictResolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('To\'qnashuvlarni hal qilish (1C vs SAP)')),
      body: BlocBuilder<ConflictBloc, ConflictState>(
        builder: (context, state) {
          if (state is ConflictLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is ConflictsLoaded) {
            if (state.conflicts.isEmpty)
              return const Center(child: Text('Hozircha to\'qnashuvlar yo\'q'));
            return ListView.builder(
              itemCount: state.conflicts.length,
              itemBuilder: (context, index) {
                final conflict = state.conflicts[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                          title: Text(
                              '${conflict.entityType}: ${conflict.entityId}')),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(child: Text('1C: ${conflict.localData}')),
                          const VerticalDivider(),
                          Expanded(child: Text('SAP: ${conflict.serverData}')),
                        ],
                      ),
                      OverflowBar(
                        children: [
                          ElevatedButton(
                              onPressed: () => context.read<ConflictBloc>().add(
                                  ResolveConflict(conflict.entityId, '1C')),
                              child: const Text('1C-ni tanlash')),
                          ElevatedButton(
                              onPressed: () => context.read<ConflictBloc>().add(
                                  ResolveConflict(conflict.entityId, 'SAP')),
                              child: const Text('SAP-ni tanlash')),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
