import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/user_stat_model.dart';

final globalStatsProvider = FutureProvider<GlobalStats>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get<Map<String, dynamic>>('/admin/stats');
  return GlobalStats.fromJson(res.data!);
});

final adminUsersProvider =
    AsyncNotifierProvider<AdminUsersNotifier, List<UserStatModel>>(
        AdminUsersNotifier.new);

class AdminUsersNotifier extends AsyncNotifier<List<UserStatModel>> {
  @override
  Future<List<UserStatModel>> build() => _fetch();

  Future<List<UserStatModel>> _fetch() async {
    final api = ref.read(apiClientProvider);
    final res = await api.get<List<dynamic>>('/admin/users');
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(UserStatModel.fromJson)
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> toggleRole(String userId, String currentRole) async {
    final api = ref.read(apiClientProvider);
    final newRole = currentRole == 'Admin' ? 'User' : 'Admin';
    await api.patch('/admin/users/$userId/role', data: {'role': newRole});
    await refresh();
  }

  Future<void> deleteUser(String userId) async {
    final api = ref.read(apiClientProvider);
    await api.delete('/admin/users/$userId');
    await refresh();
  }
}
