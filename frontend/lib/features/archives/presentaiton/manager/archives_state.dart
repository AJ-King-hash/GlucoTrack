import 'package:equatable/equatable.dart';
import '../../data/model/archives_model.dart';

enum ArchiveStatus { initial, loading, success, error }

class ArchiveState extends Equatable {
  final ArchiveStatus status;
  final List<ArchiveModel> archives;
  final String? errorMessage;

  // Pagination
  final int currentPage;
  final int totalCount;
  final int limit;
  final bool hasMore;

  // Search and Filter
  final String? searchQuery;
  final String? sortBy;
  final String sortOrder;
  final String? riskFilter;

  const ArchiveState({
    this.status = ArchiveStatus.initial,
    this.archives = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.totalCount = 0,
    this.limit = 10,
    this.hasMore = false,
    this.searchQuery,
    this.sortBy,
    this.sortOrder = 'desc',
    this.riskFilter,
  });

  ArchiveState copyWith({
    ArchiveStatus? status,
    List<ArchiveModel>? archives,
    String? errorMessage,
    int? currentPage,
    int? totalCount,
    int? limit,
    bool? hasMore,
    String? searchQuery,
    String? sortBy,
    String? sortOrder,
    String? riskFilter,
  }) {
    return ArchiveState(
      status: status ?? this.status,
      archives: archives ?? this.archives,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      riskFilter: riskFilter ?? this.riskFilter,
    );
  }

  @override
  List<Object?> get props => [
    status,
    archives,
    errorMessage,
    currentPage,
    totalCount,
    limit,
    hasMore,
    searchQuery,
    sortBy,
    sortOrder,
    riskFilter,
  ];
}
