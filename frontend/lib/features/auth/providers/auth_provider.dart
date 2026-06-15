import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

final authStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

class AuthNotifier extends AsyncNotifier<void> {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> build() async {
    final token = await _storage.read(key: 'jwt');
    ref.read(isAuthenticatedProvider.notifier).state = token != null;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt', value: token);
    ref.read(isAuthenticatedProvider.notifier).state = true;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    ref.read(isAuthenticatedProvider.notifier).state = false;
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
