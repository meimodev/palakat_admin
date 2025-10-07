import 'package:palakat_admin/core/extension/extension.dart';
import 'package:palakat_admin/core/models/column_detail.dart';
import 'package:palakat_admin/core/models/member_position.dart';
import 'package:palakat_admin/core/models/member_position_detail.dart';
import 'package:palakat_admin/core/repositories/church_repository.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/church.dart';
import '../../../core/models/column.dart' as cm;
import '../../../core/models/location.dart';
import 'church_state.dart';

part 'church_controller.g.dart';

@riverpod
class ChurchController extends _$ChurchController {
  ChurchRepository get churchRepo => ref.read(churchRepositoryProvider);

  late Church locallyStoredChurch;
  @override
  ChurchState build() {
    final church = ref
        .read(authControllerProvider)
        .value
        ?.account
        .membership
        ?.church;

    // Initialize both church and location from cached/auth state
    final initial = ChurchState(church: AsyncData(church!));

    locallyStoredChurch = church;

    Future.microtask(() {
      fetchChurch();
      fetchLocation(church.locationId!);
      fetchColumns(church.id!);
      fetchPositions(church.id!);
    });

    return initial;
  }

  Future<void> saveChurch(Church updated) async {
    final previous = state.church.value!;
    try {
      state = state.copyWith(church: AsyncLoading());

      final payload = updated.toJson().stripUnchangedFields(previous.toJson());

      final result = await churchRepo.updateChurchProfile(
        churchId: updated.id!,
        update: payload,
      );
      state = state.copyWith(church: AsyncData(result));

      // Sync cached auth account.membership.church on success
      _updateCachedAccountLocation();
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> savePosition(MemberPosition updated) async {
    final prev = state.positions;
    try {
      state = state.copyWith(positions: const AsyncLoading());

      // Find existing column to compute delta
      final currentList = prev.value ?? const <MemberPosition>[];
      final existing = currentList.firstWhere(
        (c) => c.id == updated.id,
        orElse: () => updated,
      );

      final original = existing.toJson();
      final altered = updated.toJson();
      final payload = altered.stripUnchangedFields(original);

      final result = await churchRepo.updateMemberPosition(
        positionId: updated.id ?? 0,
        update: payload,
      );

      final updatedPositions = currentList
          .map<MemberPosition>((e) => e.id == result.id ? result : e)
          .toList();
      state = state.copyWith(positions: AsyncData(updatedPositions));

      await _updateCachedAccountLocation();
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> fetchChurch() async {
    final previous = state.church.value ?? locallyStoredChurch;
    try {
      state = state.copyWith(church: AsyncLoading());
      final result = await churchRepo.fetchChurchProfile(previous.id!);
      state = state.copyWith(church: AsyncData(result));
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> saveLocation(Location updated) async {
    final previous = state.location;
    try {
      state = state.copyWith(location: const AsyncLoading());

      final originalLoc = previous.value?.toJson() ?? <String, dynamic>{};
      final alteredLoc = updated.toJson();
      final payload = alteredLoc.stripUnchangedFields(originalLoc);

      final result = await churchRepo.updateLocation(
        locationId: updated.id!,
        update: payload,
      );

      state = state.copyWith(location: AsyncData(result));

      _updateCachedAccountLocation();
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  void fetchLocation(int locationId) async {
    try {
      state = state.copyWith(location: AsyncLoading());
      final result = await churchRepo.fetchLocation(locationId);
      state = state.copyWith(location: AsyncData(result));
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<Location> fetchLocationDetail(int locationId) async {
    try {
      final fetched = await churchRepo.fetchLocation(locationId);
      return fetched;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveColumn(cm.Column updated) async {
    // Optimistically set columns to loading while saving, then update list
    final previousColumns = state.columns;
    try {
      state = state.copyWith(columns: const AsyncLoading());

      // Find existing column to compute delta
      final currentList = previousColumns.value ?? const <cm.Column>[];
      final existing = currentList.firstWhere(
        (c) => c.id == updated.id,
        orElse: () => cm.Column(
          id: updated.id,
          name: '',
          churchId: updated.churchId,
          createdAt: updated.createdAt,
        ),
      );

      final original = existing.toJson();
      final altered = updated.toJson();
      final payload = altered.stripUnchangedFields(original);

      final result = await churchRepo.updateColumn(
        columnId: updated.id ?? 0,
        update: payload,
      );

      final updatedColumns = [
        for (final c in currentList)
          if (c.id == result.id) result else c,
      ];
      state = state.copyWith(columns: AsyncData(updatedColumns));

      // Sync cached auth account.membership.church columns on success
      await _updateCachedAccountLocation();
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> createColumn(cm.Column toCreate) async {
    final previousColumns = state.columns;
    try {
      state = state.copyWith(columns: const AsyncLoading());

      final payload = {'name': toCreate.name, 'churchId': toCreate.churchId};
      final created = await churchRepo.createColumn(data: payload);

      final current = previousColumns.value ?? const <cm.Column>[];
      final updatedColumns = List<cm.Column>.from(current)..add(created);
      state = state.copyWith(columns: AsyncData(updatedColumns));

      await _updateCachedAccountLocation();
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> deleteColumn(int columnId) async {
    // Optimistically set columns to loading while deleting, then update list
    final previousColumns = state.columns;
    try {
      state = state.copyWith(columns: const AsyncLoading());
      await churchRepo.deleteColumn(columnId: columnId);

      final current = previousColumns.value ?? const <cm.Column>[];
      final updatedColumns = current.where((c) => c.id != columnId).toList();
      state = state.copyWith(columns: AsyncData(updatedColumns));
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<ColumnDetail> fetchColumn(int columnId) async {
    try {
      final fetched = await churchRepo.fetchColumn(columnId: columnId);
      return fetched;
    } catch (e) {
      rethrow;
    }
  }

  Future<MemberPositionDetail> fetchPosition(int positionId) async {
    try {
      final fetched = await churchRepo.fetchPosition(positionId: positionId);
      return fetched;
    } catch (e) {
      rethrow;
    }
  }


  void fetchColumns(int churchId) async {
    try {
      state = state.copyWith(columns: const AsyncLoading());
      final result = await churchRepo.fetchColumns(churchId: churchId);
      state = state.copyWith(columns: AsyncData(result));
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  void fetchPositions(int churchId) async {
    try {
      state = state.copyWith(positions: const AsyncLoading());
      final result = await churchRepo.fetchPositions(churchId: churchId);
      state = state.copyWith(positions: AsyncData(result));
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> createPosition(MemberPosition toCreate) async {
    final previousPositions = state.positions;
    try {
      state = state.copyWith(positions: const AsyncLoading());

      final payload = {'name': toCreate.name, 'churchId': toCreate.churchId};
      final created = await churchRepo.createMemberPosition(data: payload);

      final current = previousPositions.value ?? const <MemberPosition>[];
      final updated = List<MemberPosition>.from(current)..add(created);
      state = state.copyWith(positions: AsyncData(updated));

      await _updateCachedAccountLocation();
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> deletePosition(int positionId) async {
    final previousPositions = state.positions;
    try {
      state = state.copyWith(positions: const AsyncLoading());
      await churchRepo.deletePosition(positionId: positionId);

      final current = previousPositions.value ?? const <MemberPosition>[];
      final updated = current.where((p) => p.id != positionId).toList();
      state = state.copyWith(positions: AsyncData(updated));
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<Church> fetchChurchDetail(int churchId) async {
    try {
      final fetched = await churchRepo.fetchChurchProfile(churchId);
      return fetched;
    } catch (e) {
      rethrow;
    }
  }

  // Centralized error handler: if a slice is currently loading, restore its previous
  // value (when available) to avoid leaving the UI stuck in loading state; otherwise
  // set it to AsyncError. Always rethrow with the original stack to let callers handle UI.
  void _catchError(Object e, StackTrace st) {
    AsyncValue<T> restore<T>(AsyncValue<T> slice) {
      if (slice.isLoading) {
        if (slice.hasValue) {
          return AsyncData(slice.value as T);
        } else {
          return AsyncError(e, st);
        }
      }
      return slice;
    }

    state = state.copyWith(
      church: restore(state.church),
      location: restore(state.location),
      columns: restore(state.columns),
      positions: restore(state.positions),
    );

    // Preserve original stack trace on rethrow
    Error.throwWithStackTrace(e, st);
  }

  // Helper: Update cached auth account.membership.church.location (and locationId)
  Future<void> _updateCachedAccountLocation() async {
    final authState = ref.read(authControllerProvider);
    final currentAuth = authState.value;
    if (currentAuth == null) return;

    final currentAccount = currentAuth.account;

    final membership = currentAccount.membership;
    if (membership == null) return;

    final currentChurch = membership.church;
    if (currentChurch == null) return;

    final updatedAccount = currentAccount.copyWith(
      membership: membership.copyWith(
        church: state.church.value?.copyWith(
          location: state.location.value ?? currentChurch.location,
          membershipPositions:
              state.positions.value ?? currentChurch.membershipPositions,
          columns: state.columns.value ?? currentChurch.columns,
        ),
      ),
    );

    await ref
        .read(authControllerProvider.notifier)
        .updateCachedAccount(updatedAccount);
  }
}
