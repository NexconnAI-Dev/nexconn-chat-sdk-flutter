import 'package:flutter/foundation.dart';

/// A generic registry for managing named event handlers.
///
/// Provides thread-safe registration, removal, and batch notification of
/// handlers identified by unique string keys. Used internally by the SDK
/// to dispatch events to all registered listeners.
class HandlerRegistry<T> {
  final Map<String, T> _handlers = {};

  /// Registers a handler with the given [identifier].
  ///
  /// If a handler with the same identifier already exists, it is replaced.
  void add(String identifier, T handler) {
    _handlers[identifier] = handler;
  }

  /// Removes the handler associated with [identifier], if any.
  void remove(String identifier) {
    _handlers.remove(identifier);
  }

  /// The number of currently registered handlers.
  int get length => _handlers.length;

  /// Invokes [action] on every registered handler.
  ///
  /// Errors thrown by individual handlers are caught and logged via
  /// [debugPrint] so that one failing handler does not prevent others
  /// from being notified.
  void notify(void Function(T handler) action) {
    for (final entry in _handlers.entries) {
      try {
        action(entry.value);
      } catch (e, s) {
        debugPrint('[HandlerRegistry] error in handler "${entry.key}": $e\n$s');
      }
    }
  }

  /// Removes all registered handlers.
  void clear() {
    _handlers.clear();
  }
}
