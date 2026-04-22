/// Represents the SDK log output level for debugging and monitoring.
enum LogLevel {
  /// Disable all log output.
  none,

  /// Only output error-level logs.
  error,

  /// Output warning and error logs.
  warn,

  /// Output informational, warning, and error logs.
  info,

  /// Output debug-level and above logs.
  debug,

  /// Output all logs including verbose details.
  verbose,
}
