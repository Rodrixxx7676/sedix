import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../goals/models/goal_model.dart';
import '../../goals/providers/goals_provider.dart';
import '../../goals/screens/create_goal_sheet.dart';
import '../../goals/widgets/add_transaction_sheet.dart';
import '../../goals/widgets/goal_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.82);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: SedixColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              onCreateNew: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: SedixColors.surfaceHigh,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                builder: (_) => const CreateGoalSheet(),
              ),
            ),

            const SizedBox(height: 8),

            // Stats row
            goalsAsync.whenData((goals) => _StatsRow(goals: goals)).valueOrNull ??
                const SizedBox.shrink(),

            const SizedBox(height: 28),

            // Card carousel
            Expanded(
              child: goalsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (goals) => goals.isEmpty
                    ? _EmptyState(
                        onCreateNew: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: SedixColors.surfaceHigh,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(28)),
                          ),
                          builder: (_) => const CreateGoalSheet(),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageCtrl,
                              itemCount: goals.length,
                              onPageChanged: (i) =>
                                  setState(() => _currentPage = i),
                              itemBuilder: (_, i) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                child: GoalCard(
                                  goal: goals[i],
                                  onTap: () =>
                                      context.go('/goals/${goals[i].id}'),
                                  onAddMoney: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: SedixColors.surfaceHigh,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(28)),
                                    ),
                                    builder: (_) => AddTransactionSheet(
                                        goalId: goals[i].id),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Page dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              goals.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == i ? 20 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: _currentPage == i
                                      ? SedixColors.accent
                                      : SedixColors.shadowDark,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onCreateNew;

  const _Header({required this.onCreateNew});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sedix',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: SedixColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  'Your saving goals',
                  style: TextStyle(
                    fontSize: 13,
                    color: SedixColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Create New button
          GestureDetector(
            onTap: onCreateNew,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  Icon(Icons.add, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Create New',
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
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<GoalModel> goals;

  const _StatsRow({required this.goals});

  @override
  Widget build(BuildContext context) {
    final totalSaved = goals.fold(0.0, (s, g) => s + g.savedAmount);
    final completed = goals.where((g) => g.isCompleted).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _Stat(
            label: 'Total saved',
            value: '\$${totalSaved.toStringAsFixed(0)}',
            color: SedixColors.accent,
          ),
          const SizedBox(width: 12),
          _Stat(
            label: 'Goals',
            value: '${goals.length}',
            color: SedixColors.textPrimary,
          ),
          const SizedBox(width: 12),
          _Stat(
            label: 'Completed',
            value: '$completed',
            color: SedixColors.success,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: clayBox(radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: SedixColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateNew;

  const _EmptyState({required this.onCreateNew});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: clayBox(radius: 60),
              child: const Text('🏦', style: TextStyle(fontSize: 52)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: SedixColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first saving goal',
              style: TextStyle(
                color: SedixColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onCreateNew,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
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
                child: const Text(
                  'Create goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
