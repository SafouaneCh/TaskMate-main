import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final List<Function(bool)> _listeners = [];

  // Initialize network monitoring
  Future<void> initialize() async {
    await _checkInitialConnectivity();
    _startConnectivityMonitoring();
  }

  // Check initial connectivity
  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = result != ConnectivityResult.none;
      _notifyListeners();
    } catch (e) {
      print('Error checking connectivity: $e');
      _isConnected = false;
    }
  }

  // Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        final wasConnected = _isConnected;
        _isConnected = result != ConnectivityResult.none;

        // If we just came online, trigger sync
        if (!wasConnected && _isConnected) {
          print('Device came online - triggering sync');
          _notifyListeners();
        } else if (wasConnected && !_isConnected) {
          print('Device went offline');
          _notifyListeners();
        }
      },
      onError: (error) {
        print('Connectivity monitoring error: $error');
      },
    );
  }

  // Add listener for connectivity changes
  void addListener(Function(bool) listener) {
    _listeners.add(listener);
  }

  // Remove listener
  void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_isConnected);
    }
  }

  // Check if currently connected
  bool get isConnected => _isConnected;

  // Test internet connectivity
  Future<bool> testInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Dispose
  void dispose() {
    _connectivitySubscription?.cancel();
    _listeners.clear();
  }
}
