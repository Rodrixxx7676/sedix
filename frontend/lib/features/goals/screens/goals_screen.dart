import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/goals_provider.dart';
import '../widgets/goal_card.dart';
import 'create_goal_sheet.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: SedixColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.bullseye,
                      size: 20, color: SedixColors.accent),
                  const SizedBox(width: 10),
                  Text(
                    'My Goals',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: SedixColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: SedixColors.surfaceHigh,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(28))),
                      builder: (_) => const CreateGoalSheet(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: SedixColors.accent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: SedixColors.accent.withOpacity(0.38),
                            offset: const Offset(0, 6),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          FaIcon(FontAwesomeIcons.plus,
                              size: 13, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'New',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: goalsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (goals) => goals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: clayBox(radius: 50),
                              child: const FaIcon(FontAwesomeIcons.bullseye,
                                  size: 42, color: SedixColors.accent),
                            ),
                            const SizedBox(height: 20),
                            const Text('No goals yet',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: SedixColors.textPrimary)),
                            const SizedBox(height: 6),
                            const Text('Create your first saving goal',
                                style: TextStyle(
                                    color: SedixColors.textSecondary,
                                    fontSize: 14)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(goalsProvider.notifier).refresh(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          itemCount: goals.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) => GoalCard(
                            goal: goals[i],
                            onTap: () =>
                                context.go('/goals/${goals[i].id}'),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
