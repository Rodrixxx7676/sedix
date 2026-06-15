import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../models/goal_model.dart';
import 'goal_jar_widget.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onTap;
  final VoidCallback? onAddMoney;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        decoration: clayBox(color: SedixColors.surface, radius: 32),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CardTop(goal: goal),
            _CardBottom(goal: goal, onAddMoney: onAddMoney),
          ],
        ),
      ),
    );
  }
}

// ── Top section (illustrated background + jar) ────────────────────────────────

class _CardTop extends StatelessWidget {
  final GoalModel goal;

  const _CardTop({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDFCBA8), Color(0xFFC8AC7E)],
        ),
      ),
      child: Stack(
        children: [
          // Subtle dot texture
          Positioned.fill(child: _DotTexture()),

          // Shelf line
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF9E7B4A).withOpacity(0.45),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Jar
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 38),
              child: GoalJarWidget(
                progress: goal.progress / 100,
                width: 160,
                height: 210,
              ),
            ),
          ),

          // "Create New" emoji shortcut top right
          Positioned(
            top: 14,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                goal.emoji,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          // Nav arrows
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: FaIcon(FontAwesomeIcons.chevronLeft,
                  color: Colors.white.withOpacity(0.5), size: 16),
            ),
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: FaIcon(FontAwesomeIcons.chevronRight,
                  color: Colors.white.withOpacity(0.5), size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom section (info + button) ────────────────────────────────────────────

class _CardBottom extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback? onAddMoney;

  const _CardBottom({required this.goal, this.onAddMoney});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: SedixColors.surfaceHigh),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: goal.isCompleted
                  ? SedixColors.successLight
                  : SedixColors.accentLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: goal.isCompleted
                        ? SedixColors.success
                        : SedixColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  goal.isCompleted ? 'Completada' : 'En progreso',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: goal.isCompleted
                        ? SedixColors.success
                        : SedixColors.accent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Goal name
          Text(
            goal.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: SedixColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Label
          Text(
            goal.isCompleted ? 'Monto ahorrado' : 'Monto necesario',
            style: const TextStyle(
              fontSize: 11,
              color: SedixColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Amount
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '\$${goal.savedAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: SedixColors.textPrimary,
                  ),
                ),
                if (!goal.isCompleted)
                  TextSpan(
                    text: '/\$${goal.targetAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: SedixColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Add Money button
          if (!goal.isCompleted)
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: onAddMoney,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: SedixColors.navy,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: SedixColors.navy.withOpacity(0.35),
                        offset: const Offset(0, 6),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Agregar dinero',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: SedixColors.success,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(FontAwesomeIcons.circleCheck,
                        color: Colors.white, size: 15),
                    SizedBox(width: 6),
                    Text(
                      '¡Meta lograda!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

// ── Dot texture painter ───────────────────────────────────────────────────────

class _DotTexture extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _DotsPainter());
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.12);
    const gap = 22.0;
    for (double x = gap; x < size.width; x += gap) {
      for (double y = gap; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.5, p);
      }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter _) => false;
}
