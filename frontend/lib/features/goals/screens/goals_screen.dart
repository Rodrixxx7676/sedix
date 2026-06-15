import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/goals_provider.dart';
import '../widgets/goal_card.dart';
import 'create_goal_sheet.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const CreateGoalSheet(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New goal'),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (goals) => goals.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🏦', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('No goals yet. Create your first one!'),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(goalsProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: goals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => GoalCard(
                    goal: goals[i],
                    onTap: () => context.go('/goals/${goals[i].id}'),
                  ),
                ),
              ),
      ),
    );
  }
}
