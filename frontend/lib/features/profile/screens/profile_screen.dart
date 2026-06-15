import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../goals/providers/goals_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: SedixColors.bg,
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<Map<String, String?>>(
        future: _loadProfile(),
        builder: (context, snap) {
          final name = snap.data?['name'] ?? '—';
          final email = snap.data?['email'] ?? '—';
          final role = snap.data?['role'] ?? 'User';
          final isAdmin = role == 'Admin';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Avatar
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? SedixColors.accent.withOpacity(0.15)
                        : SedixColors.success.withOpacity(0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        offset: const Offset(-4, -4),
                        blurRadius: 10,
                      ),
                      BoxShadow(
                        color: SedixColors.shadowDark.withOpacity(0.5),
                        offset: const Offset(4, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: isAdmin ? SedixColors.accent : SedixColors.success,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: SedixColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  email,
                  style: const TextStyle(
                      fontSize: 13, color: SedixColors.textSecondary),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? SedixColors.accentLight
                        : SedixColors.successLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        isAdmin
                            ? FontAwesomeIcons.shieldHalved
                            : FontAwesomeIcons.circleUser,
                        size: 12,
                        color: isAdmin
                            ? SedixColors.accent
                            : SedixColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAdmin ? 'Admin' : 'User',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isAdmin
                              ? SedixColors.accent
                              : SedixColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Stats row
              goalsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (goals) {
                  final saved =
                      goals.fold(0.0, (s, g) => s + g.savedAmount);
                  final completed =
                      goals.where((g) => g.isCompleted).length;
                  return Row(
                    children: [
                      _StatBox(
                          value: '${goals.length}',
                          label: 'Metas',
                          icon: FontAwesomeIcons.bullseye,
                          color: SedixColors.textPrimary),
                      const SizedBox(width: 12),
                      _StatBox(
                          value: '$completed',
                          label: 'Listas',
                          icon: FontAwesomeIcons.circleCheck,
                          color: SedixColors.success),
                      const SizedBox(width: 12),
                      _StatBox(
                          value: '\$${saved.toStringAsFixed(0)}',
                          label: 'Ahorrado',
                          icon: FontAwesomeIcons.coins,
                          color: SedixColors.accent),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              if (isAdmin) ...[
                _MenuTile(
                  icon: FontAwesomeIcons.shieldHalved,
                  label: 'Panel Admin',
                  color: SedixColors.accent,
                  onTap: () => context.go('/admin'),
                ),
                const SizedBox(height: 10),
              ],

              _MenuTile(
                icon: FontAwesomeIcons.bullseye,
                label: 'Mis Metas',
                color: SedixColors.textPrimary,
                onTap: () => context.go('/goals'),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: FontAwesomeIcons.wandMagicSparkles,
                label: 'Asesor IA',
                color: SedixColors.textPrimary,
                onTap: () => context.go('/ai'),
              ),

              const SizedBox(height: 28),

              // Logout
              GestureDetector(
                onTap: () =>
                    ref.read(authNotifierProvider.notifier).logout(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(FontAwesomeIcons.rightFromBracket,
                          color: Colors.red.shade600, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, String?>> _loadProfile() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt');
    if (token == null) return {};
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decoded = utf8.decode(base64Decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return {
        'name': json['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']
                as String? ??
            json['name'] as String?,
        'email': json['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']
                as String? ??
            json['email'] as String?,
        'role': json['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']
                as String? ??
            json['role'] as String?,
      };
    } catch (_) {
      return {};
    }
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final FaIconData icon;
  final Color color;

  const _StatBox(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: clayBox(radius: 18),
          child: Column(
            children: [
              FaIcon(icon, size: 18, color: color),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: SedixColors.textPrimary)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: SedixColors.textSecondary)),
            ],
          ),
        ),
      );
}

class _MenuTile extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: clayBox(radius: 16),
          child: Row(
            children: [
              FaIcon(icon, color: color, size: 16),
              const SizedBox(width: 14),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: SedixColors.textPrimary)),
              const Spacer(),
              const FaIcon(FontAwesomeIcons.chevronRight,
                  color: SedixColors.textSecondary, size: 12),
            ],
          ),
        ),
      );
}
