import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/async_state.dart' as app_async;
import '../models/app_error.dart';
import '../services/api_service.dart';

part 'approval_repository.g.dart';

/// Model for approval rules and configurations
class ApprovalRule {
  final String id;
  final String name;
  final String description;
  final List<String> requiredApprovers;
  final int minimumApprovals;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApprovalRule({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredApprovers,
    required this.minimumApprovals,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create ApprovalRule from JSON data
  factory ApprovalRule.fromJson(Map<String, dynamic> json) {
    return ApprovalRule(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown Rule',
      description: json['description'] ?? 'No description available',
      requiredApprovers: List<String>.from(json['approvers'] ?? ['Admin']),
      minimumApprovals: 1,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Repository for managing approval rules and configurations with proper error handling
class ApprovalRepository {
  final ApiService _apiService;
  
  ApprovalRepository(this._apiService);
  
  /// Get all approval rules with proper async state handling using HTTP
  Future<app_async.AsyncState<List<ApprovalRule>>> getApprovalRulesAsync() async {
    try {
      final rulesData = await _apiService.getApprovalRules();
      final rules = rulesData.map((data) => ApprovalRule.fromJson(data)).toList();
      return app_async.AsyncSuccess(rules);
    } catch (e) {
      if (e is AppError) {
        return app_async.AsyncError(e);
      }
      return app_async.AsyncError(AppError.unknown('Failed to load approval rules: $e'));
    }
  }
  
  /// Generate mock approval rules (synchronous version for backward compatibility)
  List<ApprovalRule> getAllApprovalRules() {
    return _generateMockApprovalRules();
  }
  
  /// Internal method to generate mock approval rules
  List<ApprovalRule> _generateMockApprovalRules() {
    final now = DateTime.now();
    return [
      ApprovalRule(
        id: 'RULE-001',
        name: 'Financial Transactions',
        description: 'Approval required for all financial transactions above \$500',
        requiredApprovers: ['Pastor John', 'Treasurer Mary'],
        minimumApprovals: 2,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      ApprovalRule(
        id: 'RULE-002',
        name: 'Event Planning',
        description: 'Approval required for church events and activities',
        requiredApprovers: ['Pastor John', 'Event Coordinator Sarah'],
        minimumApprovals: 1,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      ApprovalRule(
        id: 'RULE-003',
        name: 'Facility Usage',
        description: 'Approval required for external facility usage requests',
        requiredApprovers: ['Facility Manager Tom', 'Pastor John'],
        minimumApprovals: 1,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ApprovalRule(
        id: 'RULE-004',
        name: 'Volunteer Coordination',
        description: 'Approval required for volunteer role assignments',
        requiredApprovers: ['Volunteer Coordinator Lisa'],
        minimumApprovals: 1,
        isActive: false,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Filter approval rules based on search query
  List<ApprovalRule> filterApprovalRules(
    List<ApprovalRule> rules,
    String searchQuery,
    bool? activeOnly,
  ) {
    return rules.where((rule) {
      // Search filter
      final query = searchQuery.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          rule.name.toLowerCase().contains(query) ||
          rule.description.toLowerCase().contains(query) ||
          rule.requiredApprovers.any((approver) => 
            approver.toLowerCase().contains(query));

      // Active filter
      final matchesActiveFilter = activeOnly == null || rule.isActive == activeOnly;

      return matchesQuery && matchesActiveFilter;
    }).toList();
  }

  /// Get paginated approval rules
  List<ApprovalRule> getPaginatedApprovalRules(
    List<ApprovalRule> rules,
    int page,
    int rowsPerPage,
  ) {
    final start = (page * rowsPerPage).clamp(0, rules.length);
    final end = (start + rowsPerPage).clamp(0, rules.length);
    return start < end ? rules.sublist(start, end) : <ApprovalRule>[];
  }
}

/// Riverpod provider for ApprovalRepository
@riverpod
ApprovalRepository approvalRepository(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ApprovalRepository(apiService);
}

/// Provider for all approval rules with async state handling
@riverpod
Future<List<ApprovalRule>> approvalRulesAsync(Ref ref) async {
  final repository = ref.watch(approvalRepositoryProvider);
  final result = await repository.getApprovalRulesAsync();
  
  return result.when(
    loading: () => throw StateError('Loading'),
    success: (data) => data,
    error: (error) => throw error,
  );
}

/// Provider for all approval rules (synchronous - for backward compatibility)
@riverpod
List<ApprovalRule> allApprovalRules(Ref ref) {
  final repository = ref.watch(approvalRepositoryProvider);
  return repository.getAllApprovalRules();
}

/// State class for approval screen state
class ApprovalScreenStateData {
  final String searchQuery;
  final bool? activeOnly;
  final int page;
  final int rowsPerPage;

  const ApprovalScreenStateData({
    this.searchQuery = '',
    this.activeOnly,
    this.page = 0,
    this.rowsPerPage = 10,
  });

  ApprovalScreenStateData copyWith({
    String? searchQuery,
    bool? activeOnly,
    bool clearActiveFilter = false,
    int? page,
    int? rowsPerPage,
  }) {
    return ApprovalScreenStateData(
      searchQuery: searchQuery ?? this.searchQuery,
      activeOnly: clearActiveFilter ? null : (activeOnly ?? this.activeOnly),
      page: page ?? this.page,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
    );
  }
}

/// Provider for approval screen state using Riverpod generator
@riverpod
class ApprovalScreenState extends _$ApprovalScreenState {
  @override
  ApprovalScreenStateData build() {
    return const ApprovalScreenStateData();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, page: 0);
  }

  void updateActiveFilter(bool? activeOnly) {
    state = state.copyWith(activeOnly: activeOnly, page: 0);
  }

  void clearActiveFilter() {
    state = state.copyWith(clearActiveFilter: true, page: 0);
  }

  void updatePage(int page) {
    state = state.copyWith(page: page);
  }

  void updateRowsPerPage(int rowsPerPage) {
    state = state.copyWith(rowsPerPage: rowsPerPage, page: 0);
  }
}

/// Provider for filtered approval rules
@riverpod
List<ApprovalRule> filteredApprovalRules(Ref ref) {
  final rules = ref.watch(allApprovalRulesProvider);
  final screenState = ref.watch(approvalScreenStateProvider);
  final repository = ref.watch(approvalRepositoryProvider);
  
  return repository.filterApprovalRules(
    rules,
    screenState.searchQuery,
    screenState.activeOnly,
  );
}

/// Provider for paginated approval rules
@riverpod
List<ApprovalRule> paginatedApprovalRules(Ref ref) {
  final filteredRules = ref.watch(filteredApprovalRulesProvider);
  final screenState = ref.watch(approvalScreenStateProvider);
  final repository = ref.watch(approvalRepositoryProvider);
  
  return repository.getPaginatedApprovalRules(
    filteredRules,
    screenState.page,
    screenState.rowsPerPage,
  );
}
