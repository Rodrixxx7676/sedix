class GoalModel {
  final String id;
  final String name;
  final String? description;
  final double targetAmount;
  final double savedAmount;
  final double progress;
  final bool isCompleted;
  final DateTime? deadline;
  final String emoji;
  final DateTime createdAt;

  const GoalModel({
    required this.id,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.savedAmount,
    required this.progress,
    required this.isCompleted,
    this.deadline,
    required this.emoji,
    required this.createdAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num).toDouble(),
        progress: (json['progress'] as num).toDouble(),
        isCompleted: json['isCompleted'] as bool,
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'] as String)
            : null,
        emoji: json['emoji'] as String? ?? '🏦',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  double get remaining => (targetAmount - savedAmount).clamp(0, double.infinity);
}
