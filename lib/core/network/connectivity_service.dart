import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityService {
  bool get isOnline;
  Stream<bool> get onStatusChange;
  Future<void> dispose();
}

abstract interface class ConnectivityController implements ConnectivityService {
  bool get isSimulatedOffline;
  void setSimulatedOffline(bool offline);
}

class AppConnectivityService implements ConnectivityController {
  AppConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
    _connectivity.checkConnectivity().then(_onConnectivityChanged);
  }

  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _hasNetwork = true;
  bool _simulatedOffline = false;

  @override
  bool get isOnline => _hasNetwork && !_simulatedOffline;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  @override
  bool get isSimulatedOffline => _simulatedOffline;

  @override
  void setSimulatedOffline(bool offline) {
    _simulatedOffline = offline;
    _emit();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasNetwork = results.any((r) => r != ConnectivityResult.none);
    if (hasNetwork == _hasNetwork) return;
    _hasNetwork = hasNetwork;
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) _controller.add(isOnline);
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
