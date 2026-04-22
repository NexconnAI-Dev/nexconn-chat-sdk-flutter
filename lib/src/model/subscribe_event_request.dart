import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/subscribe_type.dart';

/// Parameters for subscribing to user status events.
///
/// Specifies which users to subscribe to and the subscription duration.
class SubscribeEventParams {
  final RCIMIWSubscribeEventRequest _raw;
  SubscribeEventParams._(this._raw);

  /// Creates a [SubscribeEventParams] from an existing SDK object.
  static SubscribeEventParams fromRaw(RCIMIWSubscribeEventRequest raw) =>
      SubscribeEventParams._(raw);

  /// Creates a [SubscribeEventParams] with the given values.
  factory SubscribeEventParams({
    required SubscribeType subscribeType,
    required List<String> userIds,
    int expiry = 0,
  }) {
    return SubscribeEventParams._(
      RCIMIWSubscribeEventRequest.create(
        subscribeType: RCIMIWSubscribeType.values[subscribeType.index],
        userIds: userIds,
        expiry: expiry,
      ),
    );
  }

  /// The type of subscription (e.g., online status, typing status).
  SubscribeType get subscribeType =>
      SubscribeType.values[_raw.subscribeType?.index ?? 0];

  /// The expiry duration of the subscription (in seconds).
  int get expiry => _raw.expiry ?? 0;

  /// The list of user IDs to subscribe to.
  List<String> get userIds => _raw.userIds ?? [];

  /// The associated SDK object for advanced usage.
  RCIMIWSubscribeEventRequest get raw => _raw;
}

/// Parameters for unsubscribing from user status events.
class UnsubscribeEventParams {
  final RCIMIWSubscribeEventRequest _raw;
  UnsubscribeEventParams._(this._raw);

  /// Creates a [UnsubscribeEventParams] from an existing SDK object.
  static UnsubscribeEventParams fromRaw(RCIMIWSubscribeEventRequest raw) =>
      UnsubscribeEventParams._(raw);

  /// Creates a [UnsubscribeEventParams] with the given values.
  factory UnsubscribeEventParams({
    required SubscribeType subscribeType,
    required List<String> userIds,
  }) {
    return UnsubscribeEventParams._(
      RCIMIWSubscribeEventRequest.create(
        subscribeType: RCIMIWSubscribeType.values[subscribeType.index],
        userIds: userIds,
      ),
    );
  }

  /// The type of subscription (e.g., online status, typing status).
  SubscribeType get subscribeType =>
      SubscribeType.values[_raw.subscribeType?.index ?? 0];

  /// The list of user IDs to unsubscribe from.
  List<String> get userIds => _raw.userIds ?? [];

  /// The associated SDK object for advanced usage.
  RCIMIWSubscribeEventRequest get raw => _raw;
}

/// Parameters for querying subscribed user status.
class GetSubscribeEventParams {
  final RCIMIWSubscribeEventRequest _raw;
  GetSubscribeEventParams._(this._raw);

  /// Creates a [GetSubscribeEventParams] from an existing SDK object.
  static GetSubscribeEventParams fromRaw(RCIMIWSubscribeEventRequest raw) =>
      GetSubscribeEventParams._(raw);

  /// Creates a [GetSubscribeEventParams] with the given values.
  factory GetSubscribeEventParams({
    required SubscribeType subscribeType,
    required List<String> userIds,
  }) {
    return GetSubscribeEventParams._(
      RCIMIWSubscribeEventRequest.create(
        subscribeType: RCIMIWSubscribeType.values[subscribeType.index],
        userIds: userIds,
      ),
    );
  }

  /// The type of subscription (e.g., online status, typing status).
  SubscribeType get subscribeType =>
      SubscribeType.values[_raw.subscribeType?.index ?? 0];

  /// The list of user IDs to query.
  List<String> get userIds => _raw.userIds ?? [];

  /// The associated SDK object for advanced usage.
  RCIMIWSubscribeEventRequest get raw => _raw;
}
