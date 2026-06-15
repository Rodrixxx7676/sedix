import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/goal_model.dart';

final goalsProvider =
    AsyncNotifierProvider<GoalsNotifier, List<GoalModel>>(GoalsNotifier.new);

class GoalsNotifier extends AsyncNotifier<List<GoalModel>> {
  @override
  Future<List<GoalModel>> build() => _fetch();

  Future<List<GoalModel>> _fetch() async {
    final client = ref.read(apiClientProvider);
    final res = await client.get<List<dynamic>>('/goals');
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(GoalModel.fromJson)
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> addTransaction(
      String goalId, double amount, String type, String? note) async {
    final client = ref.read(apiClientProvider);
    await client.post('/goals/$goalId/transactions', data: {
      'amount': amount,
      'type': type,
      'note': note,
    });
    await refresh();
  }

  Future<void> createGoal(Map<String, dynamic> data) async {
    final client = ref.read(apiClientProvider);
    await client.post('/goals', data: data);
    await refresh();
  }

  Future<void> deleteGoal(String goalId) async {
    final client = ref.read(apiClientProvider);
    await client.delete('/goals/$goalId');
    await refresh();
  }
}
