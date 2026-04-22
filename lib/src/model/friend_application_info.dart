import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/friend_application_type.dart';
import '../enum/friend_application_status.dart';

/// Represents a friend request (application) with its details.
///
/// Contains information about the applicant, the current status, and the type of friend relationship being requested.
class FriendApplicationInfo {
  final RCIMIWFriendApplicationInfo _raw;
  FriendApplicationInfo._(this._raw);

  /// Creates a [FriendApplicationInfo] from an existing SDK object.
  static FriendApplicationInfo fromRaw(RCIMIWFriendApplicationInfo raw) =>
      FriendApplicationInfo._(raw);

  /// The user ID of the applicant or recipient.
  String? get userId => _raw.userId;

  /// The display name of the applicant or recipient.
  String? get name => _raw.name;

  /// The URL of the applicant's avatar image.
  String? get avatarUrl => _raw.portrait;

  /// The type of application (incoming or outgoing).
  FriendApplicationType? get applicationType =>
      _raw.applicationType != null
          ? FriendApplicationType.values[_raw.applicationType!.index]
          : null;

  /// The current status of the application (e.g., pending, accepted, rejected).
  FriendApplicationStatus? get applicationStatus =>
      _raw.applicationStatus != null
          ? FriendApplicationStatus.values[_raw.applicationStatus!.index]
          : null;

  /// The timestamp when the application was last operated on (in milliseconds).
  int? get operationTime => _raw.operationTime;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'avatarUrl': avatarUrl,
    'applicationType': applicationType?.name,
    'applicationStatus': applicationStatus?.name,
    'operationTime': operationTime,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWFriendApplicationInfo get raw => _raw;
}
