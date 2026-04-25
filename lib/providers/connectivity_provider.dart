import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/connectivity_service.dart';

/// Exposes connectivity state to the widget tree via Provider.
///
/// [isOnline] — current connectivity status.
/// [justReconnected] — briefly true after coming back online
///   so the banner can show a "Back online" confirmation
///   before hiding itself.
class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline;
  bool _justReconnected = false;
  Timer? _reconnectedTimer;

  StreamSubscription<bool>? _sub;

  ConnectivityProvider({required bool initialStatus})
      : _isOnline = initialStatus {
    _sub = ConnectivityService.instance.onConnectivityChanged.listen(
      _onStatusChanged,
    );
  }

  bool get isOnline => _isOnline;
  bool get justReconnected => _justReconnected;

  void _onStatusChanged(bool isOnline) {
    final wasOffline = !_isOnline;
    _isOnline = isOnline;

    if (isOnline && wasOffline) {
      // Briefly show "Back online" before hiding the banner.
      _justReconnected = true;
      _reconnectedTimer?.cancel();
      _reconnectedTimer = Timer(const Duration(seconds: 3), () {
        _justReconnected = false;
        notifyListeners();
      });
    } else {
      _justReconnected = false;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _reconnectedTimer?.cancel();
    super.dispose();
  }
}