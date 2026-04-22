/// Represents the type of communication channel in the Nexconn IM SDK.
enum ChannelType {
  /// One-to-one private messaging channel.
  direct,

  /// Group messaging channel for multiple participants.
  group,

  /// Open channel for large-scale real-time communication.
  open,

  /// Community channel for large persistent group communication.
  community,

  /// System notification channel.
  system,
}
