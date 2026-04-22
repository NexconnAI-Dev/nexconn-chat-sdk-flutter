/// Represents the current connection status between the client and the server.
enum ConnectionStatus {
  /// The device network is unavailable.
  networkUnavailable,

  /// Successfully connected to the server.
  connected,

  /// Currently attempting to connect to the server.
  connecting,

  /// Not connected to the server.
  unconnected,

  /// The current user has been kicked offline by another client login.
  kickedOfflineByOtherClient,

  /// The authentication token is incorrect or expired.
  tokenIncorrect,

  /// The user has been blocked by the server.
  connUserBlocked,

  /// The user has signed out.
  signOut,

  /// The connection is suspended (e.g., app moved to background).
  suspend,

  /// The connection attempt timed out.
  timeout,

  /// An unknown connection status.
  unknown,
}
