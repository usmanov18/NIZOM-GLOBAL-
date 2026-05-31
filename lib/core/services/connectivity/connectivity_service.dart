import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Internet ulanish xizmati
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool _isConnected = true;
  bool get isConnected => _isConnected;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  Future<void> initialize() async {
    _connectivity.onConnectivityChanged.listen((result) {
      final wasConnected = _isConnected;
      _isConnected = result != ConnectivityResult.none;

      if (wasConnected != _isConnected) {
        _controller.add(_isConnected);
        debugPrint(
            'Connectivity changed: ${_isConnected ? "Online" : "Offline"}');
      }
    });

    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
  }

  void dispose() {
    _controller.close();
  }
}
