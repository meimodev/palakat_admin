import 'dart:convert';

import 'package:palakat_admin/core/models/column_detail.dart';
import 'package:palakat_admin/core/models/member_position.dart';
import 'package:palakat_admin/core/models/member_position_detail.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/church.dart';
import '../../../core/models/column.dart' as cm;
import '../../../core/models/location.dart';
import '../../../core/repositories/church_repository.dart';
import 'church_state.dart';

part 'church_controller.g.dart';

@riverpod
class ChurchController extends _$ChurchController {
  @override
  ChurchState build() {
    final church = ref
        .read(authControllerProvider)
        .value
        ?.account
        .membership
        ?.church;

    // Initialize both church and location from cached/auth state
    final initial = ChurchState(
      church: AsyncData(church!),
    );

      Future.microtask(() {
        fetchLocation( church.locationId!);
        fetchColumns(church.id);
        fetchPositions(church.id);
      });

    return initial;
  }

  Future<void> saveChurch(Church updated) async {
    try {
      final repo = ref.read(churchRepositoryProvider);
      state = state.copyWith(church: AsyncLoading());
      final payload = stripUnchangedFields(
        original: state.church.value!.toJson(),
        altered: updated.toJson(),
      );

      final result = await repo.updateChurchProfile(
        churchId: updated.id,
        update: payload,
      );
      state = state.copyWith(church: AsyncData(result));
    } catch (e) {
      state = state.copyWith(church: AsyncData(state.church.value!));
      rethrow;
    }
  }

  Future<void> fetchChurch() async {
    try {
      final repo = ref.read(churchRepositoryProvider);
      state = state.copyWith(church: AsyncLoading());
      final result = await repo.fetchChurchProfile(state.church.value!.id);
      state = state.copyWith(church: AsyncData(result));
    } catch (e) {
      state = state.copyWith(church: AsyncData(state.church.value!));
      rethrow;
    }
  }

  Future<void> saveLocation(Location updated) async {
    // try {
    //   final repo = ref.read(churchRepositoryProvider);
    //   state = const AsyncLoading();
    //   final originalLoc = state.value!.location.toJson();
    //   final alteredLoc = updated.toJson();
    //   final payload = stripUnchangedFields(
    //     original: originalLoc,
    //     altered: alteredLoc,
    //   );
    //
    //   final result = await repo.updateLocation(
    //     locationId: updated.id,
    //     update: payload,
    //   );
    //
    //   final merged = state.value!.copyWith(location: result);
    //   state = AsyncData(merged);
    // } catch (e) {
    //   state = AsyncData(state.value!);
    //   rethrow;
    // }
  }

  void fetchLocation(int locationId) async {
    try {
      final repo = ref.read(churchRepositoryProvider);
      state = state.copyWith(location: AsyncLoading());
      final result = await repo.fetchLocation(locationId);
      state = state.copyWith(location: AsyncData(result));
    } catch (e) {
      state = state.copyWith(location: AsyncData(state.location.value!));
      rethrow;
    }
  }

  Future<void> saveColumn(cm.Column updated) async {
    // try {
    //   final repo = ref.read(churchRepositoryProvider);
    //   state = const AsyncLoading();
    //
    //   // Compute delta against the matching column in current state
    //   final existing = state.value!.columns.firstWhere(
    //     (c) => c.id == updated.id,
    //   );
    //   final original = existing.toJson();
    //   final altered = updated.toJson();
    //   final payload = stripUnchangedFields(
    //     original: original,
    //     altered: altered,
    //   );
    //
    //   final result = await repo.updateColumn(
    //     columnId: updated.id ?? 0,
    //     update: payload,
    //   );
    //
    //   final updatedColumns = [
    //     for (final c in state.value!.columns)
    //       if (c.id == result.id) result else c,
    //   ];
    //   state = AsyncData(state.value!.copyWith(columns: updatedColumns));
    // } catch (e) {
    //   state = AsyncData(state.value!);
    //   rethrow;
    // }
  }

  Future<void> createColumn(cm.Column toCreate) async {
    // try {
    //   final repo = ref.read(churchRepositoryProvider);
    //   state = const AsyncLoading();
    //
    //   final payload = {'name': toCreate.name, 'churchId': toCreate.churchId};
    //
    //   final created = await repo.createColumn(data: payload);
    //   final updatedColumns = List<cm.Column>.from(state.value!.columns)
    //     ..add(created);
    //   state = AsyncData(state.value!.copyWith(columns: updatedColumns));
    // } catch (e) {
    //   state = AsyncData(state.value!);
    //   rethrow;
    // }
  }

  Future<void> deleteColumn(int columnId) async {
    // try {
    //   final repo = ref.read(churchRepositoryProvider);
    //   state = const AsyncLoading();
    //   await repo.deleteColumn(columnId: columnId);
    //   final updatedColumns = state.value!.columns
    //       .where((c) => c.id != columnId)
    //       .toList();
    //   state = AsyncData(state.value!.copyWith(columns: updatedColumns));
    // } catch (e) {
    //   state = AsyncData(state.value!);
    //   rethrow;
    // }
  }

  Future<ColumnDetail> fetchColumn(int columnId) async {
    try {
      final repo = ref.read(churchRepositoryProvider);
      // Keep current data visible; optionally could set to loading but we'll fetch silently
      final fetched = await repo.fetchColumn(columnId: columnId);
      return fetched;
    } catch (e) {
      // Preserve state
      rethrow;
    }
  }

  Future<MemberPositionDetail> fetchPosition(int positionId) async {
    try {
      final repo = ref.read(churchRepositoryProvider);
      final fetched = await repo.fetchPosition(positionId: positionId);
      return fetched;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> stripUnchangedFields({
    required Map<String, dynamic> original,
    required Map<String, dynamic> altered,
  }) {
    final result = <String, dynamic>{};
    for (final key in altered.keys) {
      if (original[key].toString() != altered[key].toString()) {
        result[key] = altered[key];
      }
    }
    return result;
  }

  void fetchColumns(int churchId) async {
    try {
      final repo = ref.read(churchRepositoryProvider);
      state = state.copyWith(columns: const AsyncLoading());
      final result = await repo.fetchColumns(churchId: churchId);
      state = state.copyWith(columns: AsyncData(result));
    } catch (e, st) {
      // If we already had data, keep it visible; otherwise surface the error
      if (state.columns.hasValue && state.columns.value != null) {
        state = state.copyWith(columns: AsyncData(state.columns.value!));
      } else {
        state = state.copyWith(columns: AsyncError(e, st));
      }
      rethrow;
    }
  }

  void fetchPositions(int churchId) async {
    try {
      final repo = ref.read(churchRepositoryProvider);
      state = state.copyWith(positions: const AsyncLoading());
      final result = await repo.fetchPositions(churchId: churchId);
      state = state.copyWith(positions: AsyncData(result));
    } catch (e, st) {
      if (state.positions.hasValue && state.positions.value != null) {
        state = state.copyWith(positions: AsyncData(state.positions.value!));
      } else {
        state = state.copyWith(positions: AsyncError(e, st));
      }
      rethrow;
    }
  }
}
