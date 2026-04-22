import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Represents information about a friend in the user's contact list.
class FriendInfo {
  final RCIMIWFriendInfo _raw;
  FriendInfo._(this._raw);

  /// Creates a [FriendInfo] from an existing SDK object.
  static FriendInfo fromRaw(RCIMIWFriendInfo raw) => FriendInfo._(raw);

  /// Creates a [FriendInfo] for public SDK calls such as `setFriendInfo`.
  FriendInfo({
    String? userId,
    String? name,
    String? avatarUrl,
    String? remark,
    Map<String, String>? extProfile,
    int? addTime,
  }) : _raw = RCIMIWFriendInfo.create(
         userId: userId,
         name: name,
         portrait: avatarUrl,
         remark: remark,
         extFields: extProfile,
         addTime: addTime,
       );

  /// The unique user ID of the friend.
  String? get userId => _raw.userId;

  /// The display name of the friend.
  String? get name => _raw.name;

  /// The URL of the friend's avatar image.
  String? get avatarUrl => _raw.portrait;

  /// The friend remark (local nickname) set by the current user.
  String? get remark => _raw.remark;

  /// Extended friend profile fields as custom key-value pairs.
  Map<String, String>? get extProfile {
    final raw = _raw.extFields;
    if (raw == null) return null;
    return raw.map(
      (k, v) => MapEntry(k?.toString() ?? '', v?.toString() ?? ''),
    );
  }

  /// The timestamp when the friend was added (in milliseconds).
  int? get addTime => _raw.addTime;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'avatarUrl': avatarUrl,
    'remark': remark,
    'extProfile': extProfile,
    'addTime': addTime,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWFriendInfo get raw => _raw;
}
