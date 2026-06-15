import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/goals_provider.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/goal_jar_widget.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return goalsAsync.when(
      loading: () => const Scaffold(
          backgroundColor: SedixColors.bg,
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          backgroundColor: SedixColors.bg,
          body: Center(child: Text('Error: $e'))),
      data: (goals) {
        final goal = goals.where((g) => g.id == goalId).firstOrNull;
        if (goal == null) {
          return const Scaffold(
              backgroundColor: SedixColors.bg,
              body: Center(child: Text('Goal not found')));
        }

        return Scaffold(
          backgroundColor: SedixColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: clayBox(radius: 12),
                          child: const Center(
                            child: FaIcon(FontAwesomeIcons.chevronLeft,
                                size: 14, color: SedixColors.textPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          goal.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: SedixColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete goal?'),
                              content:
                                  const Text('This cannot be undone.'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel')),
                                FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await ref
                                .read(goalsProvider.notifier)
                                .deleteGoal(goalId);
                            if (context.mounted) Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: clayBox(radius: 12),
                          child: const Center(
                            child: FaIcon(FontAwesomeIcons.trash,
                                size: 14, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      if (goal.isCompleted)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: SedixColors.successLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              FaIcon(FontAwesomeIcons.trophy,
                                  color: SedixColors.success, size: 18),
                              SizedBox(width: 12),
                              Text(
                                'Goal completed!',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: SedixColors.success),
                              ),
                            ],
                          ),
                        ),

                      if (goal.isCompleted) const SizedBox(height: 20),

                      // Jar illustration
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: clayBox(radius: 32),
                          child: Column(
                            children: [
                              GoalJarWidget(
                                progress: goal.progress / 100,
                                width: 140,
                                height: 180,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${goal.progress.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: SedixColors.textPrimary,
                                ),
                              ),
                              Text(
                                goal.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats
                      Row(
                        children: [
                          _StatTile(
                            label: 'Saved',
                            value:
                                '\$${goal.savedAmount.toStringAsFixed(2)}',
                            icon: FontAwesomeIcons.coins,
                            color: SedixColors.accent,
                          ),
                          const SizedBox(width: 12),
                          _StatTile(
                            label: 'Target',
                            value:
                                '\$${goal.targetAmount.toStringAsFixed(2)}',
                            icon: FontAwesomeIcons.bullseye,
                            color: SedixColors.textPrimary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatTile(
                            label: 'Remaining',
                            value:
                                '\$${goal.remaining.toStringAsFixed(2)}',
                            icon: FontAwesomeIcons.hourglassHalf,
                            color: const Color(0xFFD4A017),
                          ),
                          const SizedBox(width: 12),
                          if (goal.deadline != null)
                            _StatTile(
                              label: 'Deadline',
                              value: goal.deadline!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                              icon: FontAwesomeIcons.calendarDay,
                              color: SedixColors.success,
                            )
                          else
                            Expanded(child: Container()),
                        ],
                      ),

                      if (goal.description != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: clayBox(radius: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.noteSticky,
                                      size: 13,
                                      color: SedixColors.textSecondary),
                                  SizedBox(width: 6),
                                  Text(
                                    'Notes',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: SedixColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                goal.description!,
                                style: const TextStyle(
                                  color: SedixColors.textPrimary,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      if (!goal.isCompleted)
                        GestureDetector(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: SedixColors.surfaceHigh,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(28)),
                            ),
                            builder: (_) =>
                                AddTransactionSheet(goalId: goalId),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: SedixColors.navy,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: SedixColors.navy.withOpacity(0.4),
                                  offset: const Offset(0, 8),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(FontAwesomeIcons.piggyBank,
                                    size: 16, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Add savings',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: clayBox(radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(icon, size: 13, color: color),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color),
              ),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 10,
                    color: SedixColors.textSecondary,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
}
