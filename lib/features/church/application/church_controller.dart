import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/church.dart';
import '../../../core/repositories/church_repository.dart';

part 'church_controller.g.dart';

@riverpod
class ChurchController extends _$ChurchController {
  @override
  Future<Church> build() async {
    await Future.delayed(const Duration(seconds: 4));
    final repo = ref.read(churchRepositoryProvider);
    final church = ref.read(authControllerProvider).value?.account.membership?.church;
    return repo.fetchChurchProfile(church?.id ?? 0);
  }

  void updateChurch(Church updated) {
    state = AsyncData(updated.copyWith(updatedAt: DateTime.now()));
  }

  // Mock method to get members for a column - centralizing mock data here
  List<String> getMembersForColumn(String columnId) {
    final mockColumnMembers = {
      '1': ['Alice Johnson', 'Bob Smith', 'Carol Davis', 'David Wilson'],
      '2': ['Eve Brown', 'Frank Miller', 'Grace Taylor'],
      '3': [
        'Henry Clark',
        'Ivy Martinez',
        'Jack Anderson',
        'Kate Thompson',
        'Leo Garcia',
      ],
    };
    return mockColumnMembers[columnId] ?? [];
  }

}
