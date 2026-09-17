import '../error/nc_error.dart';

/// Generic callback for operations that return a result or an error.
///
/// [result] contains the successful value and is `null` on failure.
/// [error] contains the error information. On success, `[error]?.code` is `0`.
typedef OperationHandler<T> = void Function(T? result, NCError? error);

/// Generic callback for operations that return a result, a process code, or an error.
///
/// [result] contains the successful value and may be `null` when unavailable.
/// [processCode] is an additional status code that can be used for follow-up handling.
/// [error] contains the error information and is usually `null` on success.
typedef OperationWithProcessCodeHandler<T> =
    void Function(T? result, int? processCode, NCError? error);

/// Generic callback for operations that only return an error.
///
/// On success, `[error]?.code` is `0`.
typedef ErrorHandler = void Function(NCError? error);
