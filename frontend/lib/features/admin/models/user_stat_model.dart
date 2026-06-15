class UserStatModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final int goalCount;
  final double totalSaved;
  final int completedGoals;
  final DateTime createdAt;

  const UserStatModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.goalCount,
    required this.totalSaved,
    required this.completedGoals,
    required this.createdAt,
  });

  factory UserStatModel.fromJson(Map<String, dynamic> j) => UserStatModel(
        id: j['id'] as String,
        name: j['name'] as String,
        email: j['email'] as String,
        role: j['role'] as String,
        goalCount: j['goalCount'] as int,
        totalSaved: (j['totalSaved'] as num).toDouble(),
        completedGoals: j['completedGoals'] as int,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  bool get isAdmin => role == 'Admin';
}

class GlobalStats {
  final int totalUsers;
  final int totalGoals;
  final int completedGoals;
  final double totalSaved;

  const GlobalStats({
    required this.totalUsers,
    required this.totalGoals,
    required this.completedGoals,
    required this.totalSaved,
  });

  factory GlobalStats.fromJson(Map<String, dynamic> j) => GlobalStats(
        totalUsers: j['totalUsers'] as int,
        totalGoals: j['totalGoals'] as int,
        completedGoals: j['completedGoals'] as int,
        totalSaved: (j['totalSaved'] as num).toDouble(),
      );
}
