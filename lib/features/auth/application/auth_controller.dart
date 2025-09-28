import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/core/models/auth_credentials.dart';
import 'package:palakat_admin/core/models/auth_response.dart';
import 'package:palakat_admin/core/repositories/auth_repository.dart';
import 'package:palakat_admin/core/services/local_storage_service_provider.dart';
import 'package:palakat_admin/core/models/account.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<AuthResponse?> build() {
    // Initialize from cached auth (Hive) so session is restored on app start
    final cached = ref.read(localStorageServiceProvider).currentAuth;
    return AsyncValue.data(cached);
  }

  Future<void> signIn({required String identifier, required String password}) async {
    state = const AsyncValue.loading();
    final repo = ref.read(authRepositoryProvider);
    try {
      final auth = await repo.signIn(AuthCredentials(identifier: identifier, password: password));
      state = AsyncValue.data(auth);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.signOut();
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  /// Force sign-out locally without calling the API.
  /// Useful for 401 handling to avoid provider cycles.
  Future<void> forceSignOut() async {
    try {
      await ref.read(localStorageServiceProvider).clear();
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  /// Update the locally cached auth by replacing its Account, then sync provider state.
  /// Safe no-op if there is no current cached auth (e.g., signed out).
  Future<void> updateCachedAccount(Account updatedAccount) async {
    final storage = ref.read(localStorageServiceProvider);
    final current = storage.currentAuth;
    if (current == null) return;

    final newAuth = current.copyWith(account: updatedAccount);
    await storage.saveAuth(newAuth);
    state = AsyncValue.data(newAuth);
  }
}
