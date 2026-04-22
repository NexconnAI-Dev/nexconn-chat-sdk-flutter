import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/friend_relation_type.dart';

/// Represents the friend relationship status between the current user and another user.
class FriendRelationInfo {
  final RCIMIWFriendRelationInfo _raw;
  FriendRelationInfo._(this._raw);

  /// Creates a [FriendRelationInfo] from an existing SDK object.
  static FriendRelationInfo fromRaw(RCIMIWFriendRelationInfo raw) =>
      FriendRelationInfo._(raw);

  /// The user ID of the other user.
  String? get userId => _raw.userId;

  /// The type of friend relationship (e.g., none, one-way, mutual).
  FriendRelationType? get relation =>
      _raw.relation != null
          ? FriendRelationType.values[_raw.relation!.index]
          : null;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'relation': relation?.name,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWFriendRelationInfo get raw => _raw;
}
