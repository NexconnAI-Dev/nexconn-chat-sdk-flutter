import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/group_member_role.dart';

/// Represents detailed information about a member in a group.
class GroupMemberInfo {
  final RCIMIWGroupMemberInfo _raw;
  GroupMemberInfo._(this._raw);

  /// Creates a [GroupMemberInfo] from an existing SDK object.
  static GroupMemberInfo fromRaw(RCIMIWGroupMemberInfo raw) =>
      GroupMemberInfo._(raw);

  /// The unique user ID of the group member.
  String? get userId => _raw.userId;

  /// The URL of the member's avatar image.
  String? get avatarUrl => _raw.portraitUri;

  /// The display name of the member.
  String? get name => _raw.name;

  /// The member's nickname within the group.
  String? get nickname => _raw.nickname;

  /// Additional custom data associated with the member.
  String? get extra => _raw.extra;

  /// The timestamp when the member joined the group (in milliseconds).
  int? get joinedTime => _raw.joinedTime;

  /// The member's role in the group (e.g., owner, admin, member).
  GroupMemberRole? get role =>
      _raw.role != null ? GroupMemberRole.values[_raw.role!.index] : null;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'avatarUrl': avatarUrl,
    'name': name,
    'nickname': nickname,
    'extra': extra,
    'joinedTime': joinedTime,
    'role': role?.name,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWGroupMemberInfo get raw => _raw;
}
