import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// User information embedded within a message in the Nexconn IM SDK.
///
/// Contains the sender's profile data including user ID, display name, avatar URL, alias, and extra information.
/// This is attached to messages so recipients can display sender details without additional queries.
class UserInfo {
  final RCIMIWUserInfo _raw;

  UserInfo._(this._raw);

  /// Creates a [UserInfo] from an existing SDK object.
  static UserInfo fromRaw(RCIMIWUserInfo raw) => UserInfo._(raw);

  /// The unique user ID of the sender.
  String? get userId => _raw.userId;

  /// The display name of the user.
  String? get name => _raw.name;

  /// The URL of the user's avatar image.
  String? get avatarUrl => _raw.portrait;

  /// The alias (nickname) set for this user, if any.
  String? get alias => _raw.alias;

  /// Additional extra information associated with the user.
  String? get extra => _raw.extra;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'avatarUrl': avatarUrl,
    'alias': alias,
    'extra': extra,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWUserInfo get raw => _raw;
}
