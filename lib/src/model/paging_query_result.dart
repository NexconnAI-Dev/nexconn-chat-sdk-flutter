import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// A generic paginated query result container.
///
/// Wraps a page of data items along with pagination metadata
/// such as the next page token and total count.
class PagingQueryResult<T> {
  final RCIMIWPagingQueryResult _raw;

  /// The list of data items in the current page.
  final List<T>? data;

  PagingQueryResult._(this._raw, this.data);

  /// Creates a [PagingQueryResult] from an existing SDK object and parsed data.
  static PagingQueryResult<T> fromRaw<T>(
    RCIMIWPagingQueryResult raw,
    List<T>? data,
  ) => PagingQueryResult._(raw, data);

  /// The token for fetching the next page, or `null` if no more pages.
  String? get pageToken => _raw.pageToken;

  /// The total number of items across all pages.
  int? get totalCount => _raw.totalCount;

  /// The associated SDK object for advanced usage.
  RCIMIWPagingQueryResult get raw => _raw;
}
