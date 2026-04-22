import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Options for configuring paginated queries.
///
/// Controls page size, pagination token, and sort order for list-style API requests.
class PagingQueryOption {
  final RCIMIWPagingQueryOption _raw;
  PagingQueryOption._(this._raw);

  /// Creates a [PagingQueryOption] with optional pagination settings.
  ///
  /// [pageSize] sets the number of items per page.
  /// [pageToken] is the token for fetching the next page.
  /// [order] controls the sort order (`true` for ascending).
  PagingQueryOption({int? pageSize, String? pageToken, bool? order})
    : this._(
        RCIMIWPagingQueryOption.create(
          count: pageSize,
          pageToken: pageToken,
          order: order,
        ),
      );

  /// Creates a [PagingQueryOption] from an existing SDK object.
  static PagingQueryOption fromRaw(RCIMIWPagingQueryOption raw) =>
      PagingQueryOption._(raw);

  /// The pagination token for the current page position.
  String? get pageToken => _raw.pageToken;

  /// The number of items per page.
  int? get count => _raw.count;

  /// The sort order (`true` for ascending, `false` for descending).
  bool? get order => _raw.order;

  /// The associated SDK object for advanced usage.
  RCIMIWPagingQueryOption get raw => _raw;
}
