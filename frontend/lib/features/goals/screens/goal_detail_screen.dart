import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/goals_provider.dart';
import '../widgets/add_transaction_sheet.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return goalsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (goals) {
        final goal = goals.where((g) => g.id == goalId).firstOrNull;
        if (goal == null) {
          return const Scaffold(body: Center(child: Text('Goal not found')));
        }

        final scheme = Theme.of(context).colorScheme;
        final percent = (goal.progress / 100).clamp(0.0, 1.0);

        return Scaffold(
          appBar: AppBar(
            title: Text(goal.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete goal?'),
                      content: const Text('This cannot be undone.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await ref.read(goalsProvider.notifier).deleteGoal(goalId);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          floatingActionButton: goal.isCompleted
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AddTransactionSheet(goalId: goalId),
                  ),
                  icon: const Icon(Icons.savings),
                  label: const Text('Add savings'),
                ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (goal.isCompleted)
                Card(
                  color: scheme.primaryContainer,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text('🎉', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 12),
                        Text('Goal completed!',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Center(
                child: CircularPercentIndicator(
                  radius: 90,
                  lineWidth: 12,
                  percent: percent,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(goal.emoji, style: const TextStyle(fontSize: 32)),
                      Text(
                        '${goal.progress.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  progressColor: scheme.primary,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 32),
              _InfoRow('Saved', '\$${goal.savedAmount.toStringAsFixed(2)}'),
              _InfoRow('Target', '\$${goal.targetAmount.toStringAsFixed(2)}'),
              _InfoRow('Remaining', '\$${goal.remaining.toStringAsFixed(2)}'),
              if (goal.deadline != null)
                _InfoRow('Deadline',
                    goal.deadline!.toLocal().toString().split(' ')[0]),
              if (goal.description != null) ...[
                const SizedBox(height: 16),
                Text(goal.description!,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
