import 'error_codes.dart';

/// Result codes returned by the Nexconn engine for SDK-level operations.
enum NCEngineResultCode {
  /// The operation completed successfully.
  success,

  /// One or more parameters are invalid.
  paramError,

  /// The engine has been destroyed and can no longer be used.
  engineDestroyed,

  /// An internal SDK error occurred.
  nativeOperationError,

  /// The result is unknown or could not be determined.
  resultUnknown,
}

/// Represents an error returned by the Nexconn IM SDK.
///
/// Contains an integer [code] from the server or SDK, an optional
/// human-readable [message], and a [reason] string automatically resolved
/// from [errorCodeReasons] when the code is known.
class NCError {
  /// Optional human-readable error message.
  final String? message;

  /// Numeric error code returned by the server or the SDK.
  final int? code;

  /// Localized reason string looked up from [errorCodeReasons], or `null`
  /// if the code is not mapped.
  final String? reason;

  /// Creates an [NCError] with the given [code] and optional [message].
  ///
  /// The [reason] is automatically resolved from [errorCodeReasons].
  NCError({this.code, this.message})
    : reason = (code != null) ? errorCodeReasons[code] : null;

  /// Whether this error represents a successful operation (code == 0).
  bool get isSuccess => code == 0;

  /// Serializes this error to a JSON-compatible map.
  /// Converts this error to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'code': code,
    if (message != null) 'message': message,
    if (reason != null) 'reason': reason,
  };

  @override
  String toString() {
    final parts = <String>['NCError(code: $code'];
    if (message != null) parts.add('message: $message');
    if (reason != null) parts.add('reason: $reason');
    parts.add(')');
    return parts.join(', ');
  }
}
