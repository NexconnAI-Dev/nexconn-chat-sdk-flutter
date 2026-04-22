import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'media_message.dart';
import 'message.dart';

/// Parameters for creating a [FileMessage].
class FileMessageParams extends MessageParams {
  /// The local file path of the file to send.
  final String path;

  /// Creates [FileMessageParams] with the required file [path].
  FileMessageParams({
    required this.path,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// A file message in the Nexconn IM SDK.
///
/// Extends [MediaMessage] with file-specific properties such as file name, file type, and file size.
class FileMessage extends MediaMessage {
  /// Creates a [FileMessage] by wrapping a raw message object.
  FileMessage.wrap(super.raw) : super.wrap();

  /// Creates a [FileMessage] from an existing SDK object.
  static FileMessage fromRaw(RCIMIWFileMessage raw) => FileMessage.wrap(raw);

  RCIMIWFileMessage get _fileRaw => raw as RCIMIWFileMessage;

  /// The name of the file.
  String? get name => _fileRaw.name;

  /// The file type extension (e.g., "pdf", "docx").
  String? get fileType => _fileRaw.fileType;

  /// The file size in bytes.
  int? get size => _fileRaw.size;

  @override
  Map<String, dynamic> extraJson() => {
    ...super.extraJson(),
    'name': name,
    'fileType': fileType,
    'size': size,
  };
}
