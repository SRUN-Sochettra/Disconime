import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../widgets/global_error_handler.dart';

/// Monitors real internet connectivity and exposes a stream
/// of [bool] values — true = online, false = offline.
///
/// Uses [connectivity_plus] for fast network-change events
/// and [internet_connection_checker_plus] to verify actual
/// internet reachability (not just WiFi/mobile association).
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _controller.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  /// Call once in [main] before [runApp].
  Future<void> init() async {
    try {
      // Check current status.
      _isOnline = await InternetConnection().hasInternetAccess;

      // Listen for connectivity changes.
      _connectivitySub = Connectivity().onConnectivityChanged.listen(
        (results) async {
          try {
            if (results.contains(ConnectivityResult.none)) {
              _updateStatus(false);
              return;
            }
            // Verify actual internet access — not just network association.
            final hasAccess = await InternetConnection().hasInternetAccess;
            _updateStatus(hasAccess);
          } catch (e, stack) {
            debugPrint('[ConnectivityService] listener error: $e');
            GlobalErrorHandler.reportError(e, stack);
          }
        },
      );

      debugPrint(
        '[ConnectivityService] Initialised. Online: $_isOnline',
      );
    } catch (e, stack) {
      debugPrint('[ConnectivityService] init error: $e');
      GlobalErrorHandler.reportError(e, stack);
    }
  }

  void _updateStatus(bool isOnline) {
    if (_isOnline == isOnline) return; // No change — skip broadcast.
    _isOnline = isOnline;
    _controller.add(_isOnline);
    debugPrint('[ConnectivityService] Status changed: online=$_isOnline');
  }

  /// Only for testing. Forces the online state.
  @visibleForTesting
  void setMockOnline(bool online) {
    _isOnline = online;
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _controller.close();
  }
}