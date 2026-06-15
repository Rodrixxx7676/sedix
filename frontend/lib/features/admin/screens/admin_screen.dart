import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../models/user_stat_model.dart';
import '../providers/admin_provider.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(globalStatsProvider);
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      backgroundColor: SedixColors.bg,
      appBar: AppBar(
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.shieldHalved,
                size: 18, color: SedixColors.accent),
            SizedBox(width: 8),
            Text('Panel Admin'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(globalStatsProvider);
          await ref.read(adminUsersProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Global stats
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Text('Error: $e', style: const TextStyle(color: Colors.red)),
              data: (stats) => _StatsGrid(stats: stats),
            ),

            const SizedBox(height: 24),
            const Text(
              'Usuarios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: SedixColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // User list
            usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Text('Error: $e', style: const TextStyle(color: Colors.red)),
              data: (users) => Column(
                children: users
                    .map((u) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _UserCard(
                            user: u,
                            onToggleRole: () => ref
                                .read(adminUsersProvider.notifier)
                                .toggleRole(u.id, u.role),
                            onDelete: () async {
                              final confirm = await _confirmDelete(context, u.name);
                              if (confirm == true) {
                                await ref
                                    .read(adminUsersProvider.notifier)
                                    .deleteUser(u.id);
                              }
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext ctx, String name) =>
      showDialog<bool>(
        context: ctx,
        builder: (_) => AlertDialog(
          title: const Text('¿Eliminar usuario?'),
          content: Text(
              'Se eliminará permanentemente a $name y todas sus metas.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.red),
                child: const Text('Eliminar')),
          ],
        ),
      );
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final GlobalStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          _StatCard(
              label: 'Usuarios',
              value: '${stats.totalUsers}',
              icon: FontAwesomeIcons.users,
              color: SedixColors.accent),
          _StatCard(
              label: 'Metas totales',
              value: '${stats.totalGoals}',
              icon: FontAwesomeIcons.bullseye,
              color: SedixColors.textPrimary),
          _StatCard(
              label: 'Completadas',
              value: '${stats.completedGoals}',
              icon: FontAwesomeIcons.circleCheck,
              color: SedixColors.success),
          _StatCard(
              label: 'Total ahorrado',
              value: '\$${stats.totalSaved.toStringAsFixed(0)}',
              icon: FontAwesomeIcons.coins,
              color: const Color(0xFFD4A017)),
        ],
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final FaIconData icon;
  final Color color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: clayBox(radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FaIcon(icon, size: 20, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
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
          ],
        ),
      );
}

// ── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final UserStatModel user;
  final VoidCallback onToggleRole;
  final VoidCallback onDelete;

  const _UserCard(
      {required this.user,
      required this.onToggleRole,
      required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: clayBox(radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: user.isAdmin
                        ? SedixColors.accent.withOpacity(0.15)
                        : SedixColors.success.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: user.isAdmin
                          ? SedixColors.accent
                          : SedixColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: SedixColors.textPrimary,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: SedixColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Role badge
                GestureDetector(
                  onTap: onToggleRole,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: user.isAdmin
                          ? SedixColors.accentLight
                          : SedixColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: user.isAdmin
                            ? SedixColors.accent
                            : SedixColors.success,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: SedixColors.shadowDark),
            const SizedBox(height: 10),
            Row(
              children: [
                _Mini('${user.goalCount}', 'metas'),
                const SizedBox(width: 16),
                _Mini('${user.completedGoals}', 'listas'),
                const SizedBox(width: 16),
                _Mini('\$${user.totalSaved.toStringAsFixed(0)}', 'ahorrado'),
                const Spacer(),
                GestureDetector(
                  onTap: onDelete,
                  child: const FaIcon(FontAwesomeIcons.trash,
                      size: 15, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      );
}

class _Mini extends StatelessWidget {
  final String value;
  final String label;

  const _Mini(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: SedixColors.textPrimary,
              )),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: SedixColors.textSecondary)),
        ],
      );
}
