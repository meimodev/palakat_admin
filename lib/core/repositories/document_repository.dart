import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/core/services/http_service.dart';
import 'package:palakat_admin/core/models/document.dart';
import 'package:palakat_admin/core/models/app_error.dart';
import 'package:palakat_admin/core/models/request/request.dart';
import 'package:palakat_admin/core/models/response/response.dart';
import 'package:palakat_admin/core/utils/error_mapper.dart';
import 'package:palakat_admin/core/config/endpoint.dart';
import 'package:palakat_admin/core/repositories/church_repository.dart';
import 'package:palakat_admin/core/services/local_storage_service_provider.dart';

part 'document_repository.g.dart';

@riverpod
DocumentRepository documentRepository(Ref ref) => DocumentRepository(ref);

class DocumentRepository {
  final Ref _ref;
  DocumentRepository(this._ref);

  Future<PaginationResponseWrapper<Document>> fetchDocuments({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.documents,
        queryParameters: query,
      );

      final data = response.data ?? {};
      return PaginationResponseWrapper.fromJson(
        data,
        (e) => Document.fromJson(e as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch documents');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch documents', e, st);
    }
  }

  Future<DocumentSettings> getSettings() async {
    try {
      // Get churchId from authenticated user
      final auth = _ref.read(localStorageServiceProvider).currentAuth;
      final churchId = auth?.account.membership?.church?.id;
      
      if (churchId == null) {
        throw AppError.network('Church ID not found in authenticated user');
      }

      // Fetch church detail
      final churchRepo = _ref.read(churchRepositoryProvider);
      final church = await churchRepo.fetchChurchProfile(churchId);

      // Extract documentAccountNumber
      final documentAccountNumber = church.documentAccountNumber;
      if (documentAccountNumber == null || documentAccountNumber.isEmpty) {
        throw AppError.network('Document account number not found in church profile');
      }

      return DocumentSettings(identityNumberTemplate: documentAccountNumber);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to fetch document settings');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to fetch document settings', e, st);
    }
  }

  Future<DocumentSettings> updateIdentityTemplate(String newTemplate) async {
    try {
      // Get churchId from authenticated user
      final auth = _ref.read(localStorageServiceProvider).currentAuth;
      final churchId = auth?.account.membership?.church?.id;
      
      if (churchId == null) {
        throw AppError.network('Church ID not found in authenticated user');
      }

      // Update church documentAccountNumber
      final churchRepo = _ref.read(churchRepositoryProvider);
      final updatedChurch = await churchRepo.updateChurchProfile(
        churchId: churchId,
        update: {'documentAccountNumber': newTemplate},
      );

      // Return updated document settings
      final documentAccountNumber = updatedChurch.documentAccountNumber;
      if (documentAccountNumber == null || documentAccountNumber.isEmpty) {
        throw AppError.network('Document account number not found after update');
      }

      return DocumentSettings(identityNumberTemplate: documentAccountNumber);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e, 'Failed to update identity template');
    } catch (e, st) {
      throw ErrorMapper.unknown('Failed to update identity template', e, st);
    }
  }
}


@riverpod
Future<DocumentSettings> documentSettings(Ref ref) async {
  final repo = ref.watch(documentRepositoryProvider);
  try {
    return await repo.getSettings();
  } catch (e) {
    if (e is AppError) rethrow;
    throw AppError.unknown('Failed to load document settings: $e');
  }
}
