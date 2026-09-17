import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// A draft saved while editing an existing message.
class EditedMessageDraft {
  final RCIMIWEditedMessageDraft _raw;

  EditedMessageDraft._(this._raw);

  /// Creates an edited-message draft.
  factory EditedMessageDraft({
    required String messageId,
    required String? content,
  }) {
    return EditedMessageDraft._(
      RCIMIWEditedMessageDraft.create(messageUId: messageId, content: content),
    );
  }

  /// Creates a draft from the underlying SDK value.
  static EditedMessageDraft fromRaw(RCIMIWEditedMessageDraft raw) =>
      EditedMessageDraft._(raw);

  /// The server-generated ID of the message being edited.
  String? get messageId => _raw.messageUId;

  /// The application-defined draft content.
  String? get content => _raw.content;

  /// The associated SDK object for advanced usage.
  RCIMIWEditedMessageDraft get raw => _raw;

  Map<String, dynamic> toJson() => {'messageId': messageId, 'content': content};
}
