import 'package:equatable/equatable.dart';

class PaginationParams extends Equatable {
  final int page;
  final int limit;

  const PaginationParams({
    this.page = 1,
    this.limit = 20,
  });

  PaginationParams copyWith({
    int? page,
    int? limit,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQuery() {
    return {
      'page': page,
      'limit': limit,
    };
  }

  @override
  List<Object?> get props => [page, limit];
}