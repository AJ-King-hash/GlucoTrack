import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalCount;
  final int limit;
  final bool isLoading;
  final VoidCallback? onLoadMore;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalCount,
    required this.limit,
    this.isLoading = false,
    this.onLoadMore,
  });

  int get totalPages => (totalCount / limit).ceil();
  bool get hasMore => currentPage * limit < totalCount;

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Page info
          Text(
            'Showing ${((currentPage - 1) * limit) + 1} - ${(currentPage * limit).clamp(0, totalCount)} of $totalCount',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),

          // Load more button or loading indicator
          if (hasMore)
            isLoading
                ? const CircularProgressIndicator()
                : TextButton(
                  onPressed: onLoadMore,
                  child: const Text('Load More'),
                )
          else if (currentPage > 1)
            Text(
              'No more items',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }
}
