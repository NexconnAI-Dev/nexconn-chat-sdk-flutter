import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/subscribe_type.dart';
import 'user_profile.dart';

/// Represents subscribed status information received from the server.
///
/// Contains details about a user's subscription status, including the subscriber's profile and individual event details.
class SubscribeStatusInfo {
  final RCIMIWSubscribeInfoEvent _raw;
  SubscribeStatusInfo._(this._raw);

  /// Creates a [SubscribeStatusInfo] from an existing SDK object.
  static SubscribeStatusInfo fromRaw(RCIMIWSubscribeInfoEvent raw) =>
      SubscribeStatusInfo._(raw);

  /// The user ID of the subscriber.
  String? get userId => _raw.userId;

  /// The type of subscription (e.g., online status, typing status).
  SubscribeType? get subscribeType =>
      _raw.subscribeType != null
          ? SubscribeType.values[_raw.subscribeType!.index]
          : null;

  /// The timestamp when the subscription was created (in milliseconds).
  int? get subscribeTime => _raw.subscribeTime;

  /// The expiry time of the subscription (in milliseconds).
  int? get expiry => _raw.expiry;

  /// The profile of the subscribed user.
  UserProfile? get userProfile =>
      _raw.userProfile != null ? UserProfile.fromRaw(_raw.userProfile!) : null;

  /// The list of detailed subscription status changes.
  List<SubscribeStatusDetail> get details =>
      _raw.details?.map((e) => SubscribeStatusDetail.fromRaw(e)).toList() ?? [];

  /// The associated SDK object for advanced usage.
  RCIMIWSubscribeInfoEvent get raw => _raw;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'subscribeType': subscribeType?.name,
    'subscribeTime': subscribeTime,
    'expiry': expiry,
    'userProfile': userProfile?.toJson(),
    'details': details.map((e) => e.toJson()).toList(),
  };
}

/// Represents a single detail entry within subscribed status information.
class SubscribeStatusDetail {
  final RCIMIWSubscribeEventDetail _raw;
  SubscribeStatusDetail._(this._raw);

  /// Creates a [SubscribeStatusDetail] from an existing SDK object.
  static SubscribeStatusDetail fromRaw(RCIMIWSubscribeEventDetail raw) =>
      SubscribeStatusDetail._(raw);

  /// The value of the subscription event (application-defined).
  int? get eventValue => _raw.eventValue;

  /// The timestamp when the event value changed (in milliseconds).
  int? get changeTime => _raw.changeTime;

  /// The platform from which the event originated.
  NCPlatform? get platform =>
      _raw.platform != null ? NCPlatform.values[_raw.platform!.index] : null;

  /// The associated SDK object for advanced usage.
  RCIMIWSubscribeEventDetail get raw => _raw;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'eventValue': eventValue,
    'changeTime': changeTime,
    'platform': platform?.name,
  };
}

/// Represents the client platform for subscription events.
enum NCPlatform { other, ios, android, web, pc, miniweb, harmonyos }
