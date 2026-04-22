import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Represents information about a favorited (bookmarked) user.
class FavoriteInfo {
  final RCIMIWFollowInfo _raw;
  FavoriteInfo._(this._raw);

  /// Creates a [FavoriteInfo] from an existing SDK object.
  static FavoriteInfo fromRaw(RCIMIWFollowInfo raw) => FavoriteInfo._(raw);

  /// The user ID of the favorited user.
  String? get userId => _raw.userId;

  /// The timestamp when the user was favorited (in milliseconds).
  int? get time => _raw.time;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {'userId': userId, 'time': time};

  /// The associated SDK object for advanced usage.
  RCIMIWFollowInfo get raw => _raw;
}
