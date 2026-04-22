import '../enum/connection_status.dart';

/// Event fired when the SDK connection status changes.
class ConnectionStatusChangedEvent {
  /// The current connection status.
  final ConnectionStatus status;

  /// Creates a [ConnectionStatusChangedEvent].
  const ConnectionStatusChangedEvent({required this.status});
}

/// Callback invoked when the connection status changes.
typedef OnConnectionStatusChanged =
    void Function(ConnectionStatusChangedEvent event);
