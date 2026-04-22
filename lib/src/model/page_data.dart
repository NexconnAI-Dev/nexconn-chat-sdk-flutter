/// Paginated result containing only the current page data.
class PageData<T> {
  /// The list of items in the current page.
  final List<T> data;

  /// Creates a [PageData] with the given [data].
  const PageData({required this.data});
}

/// Paginated result containing both the current page data and total count.
class PageResult<T> {
  /// The list of items in the current page.
  final List<T> data;

  /// The total number of items across all pages.
  final int totalCount;

  /// Creates a [PageResult] with the given [data] and [totalCount].
  const PageResult({required this.data, required this.totalCount});
}
