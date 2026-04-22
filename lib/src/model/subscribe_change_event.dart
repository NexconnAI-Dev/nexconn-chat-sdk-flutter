import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/subscribe_type.dart';
import '../enum/subscribe_operation_type.dart';

/// Represents a subscription relation change event.
///
/// Received when a user's subscription status changes (e.g., someone subscribes to or unsubscribes from the current user's status).
class SubscribeChangeEvent {
  final RCIMIWSubscribeEvent _raw;
  SubscribeChangeEvent._(this._raw);

  /// Creates a [SubscribeChangeEvent] from an existing SDK object.
  static SubscribeChangeEvent fromRaw(RCIMIWSubscribeEvent raw) =>
      SubscribeChangeEvent._(raw);

  /// The user ID of the subscriber.
  String? get userId => _raw.userId;

  /// The type of subscription (e.g., online status, typing status).
  SubscribeType? get subscribeType =>
      _raw.subscribeType != null
          ? SubscribeType.values[_raw.subscribeType!.index]
          : null;

  /// The operation type (subscribe or unsubscribe).
  SubscribeOperationType? get operationType =>
      _raw.operationType != null
          ? SubscribeOperationType.values[_raw.operationType!.index]
          : null;

  /// The timestamp when the subscription action occurred (in milliseconds).
  int? get subscribeTime => _raw.subscribeTime;

  /// The expiry time of the subscription (in milliseconds).
  int? get expiry => _raw.expiry;

  /// The associated SDK object for advanced usage.
  RCIMIWSubscribeEvent get raw => _raw;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'subscribeType': subscribeType?.name,
    'operationType': operationType?.name,
    'subscribeTime': subscribeTime,
    'expiry': expiry,
  };
}
