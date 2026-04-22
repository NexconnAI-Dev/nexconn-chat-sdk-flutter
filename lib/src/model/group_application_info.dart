import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/group_application_status.dart';
import '../enum/group_application_direction.dart';
import '../enum/group_application_type.dart';
import 'group_member_info.dart';

/// Represents a group join or invite application.
///
/// Contains information about who applied, who invited, the current status of the application, and the associated reason.
class GroupApplicationInfo {
  final RCIMIWGroupApplicationInfo _raw;
  GroupApplicationInfo._(this._raw);

  /// Creates a [GroupApplicationInfo] from an existing SDK object.
  static GroupApplicationInfo fromRaw(RCIMIWGroupApplicationInfo raw) =>
      GroupApplicationInfo._(raw);

  /// The group ID that the application is associated with.
  String? get groupId => _raw.groupId;

  /// The member info of the user who is joining the group.
  GroupMemberInfo? get joinMemberInfo =>
      _raw.joinMemberInfo != null
          ? GroupMemberInfo.fromRaw(_raw.joinMemberInfo!)
          : null;

  /// The member info of the user who sent the invitation.
  GroupMemberInfo? get inviterInfo =>
      _raw.inviterInfo != null
          ? GroupMemberInfo.fromRaw(_raw.inviterInfo!)
          : null;

  /// The member info of the user who processed the application.
  GroupMemberInfo? get operatorInfo =>
      _raw.operatorInfo != null
          ? GroupMemberInfo.fromRaw(_raw.operatorInfo!)
          : null;

  /// The current status of the application (e.g., pending, approved, rejected).
  GroupApplicationStatus? get status =>
      _raw.status != null
          ? GroupApplicationStatus.values[_raw.status!.index]
          : null;

  /// The direction of the application (incoming or outgoing).
  GroupApplicationDirection? get direction =>
      _raw.direction != null
          ? GroupApplicationDirection.values[_raw.direction!.index]
          : null;

  /// The type of application (join request or invitation).
  GroupApplicationType? get type =>
      _raw.type != null ? GroupApplicationType.values[_raw.type!.index] : null;

  /// The timestamp when the application was processed (in milliseconds).
  int? get operationTime => _raw.operationTime;

  /// The reason or message attached to the application.
  String? get reason => _raw.reason;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'groupId': groupId,
    'joinMemberInfo': joinMemberInfo?.toJson(),
    'inviterInfo': inviterInfo?.toJson(),
    'operatorInfo': operatorInfo?.toJson(),
    'status': status?.name,
    'direction': direction?.name,
    'type': type?.name,
    'operationTime': operationTime,
    'reason': reason,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWGroupApplicationInfo get raw => _raw;
}
