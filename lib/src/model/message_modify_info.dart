import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

import '../enum/message_modify_status.dart';
import '../internal/converter.dart';
import '../message/message.dart';

/// Describes the latest modification applied to a message.
class MessageModifyInfo {
  final RCIMIWMessageModifyInfo _raw;

  MessageModifyInfo._(this._raw);

  /// Creates modification information from the underlying SDK value.
  static MessageModifyInfo fromRaw(RCIMIWMessageModifyInfo raw) =>
      MessageModifyInfo._(raw);

  /// The modification timestamp in milliseconds.
  int? get timestamp => _raw.timestamp;

  /// The modified message content.
  Message? get content =>
      _raw.content == null ? null : Message.fromRaw(_raw.content!);

  /// The current modification state.
  MessageModifyStatus? get status =>
      _raw.status == null
          ? null
          : Converter.fromRCMessageModifyStatus(_raw.status!);

  /// The associated SDK object for advanced usage.
  RCIMIWMessageModifyInfo get raw => _raw;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'content': content?.toJson(),
    'status': status?.name,
  };
}
