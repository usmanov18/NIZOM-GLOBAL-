import 'dart:async';
import 'package:flutter/foundation.dart';

import '../connectivity/connectivity_service.dart';
import 'sync_worker_service.dart';

/// App lifecycle ichida sync worker'ni avtomatik yuritish uchun scheduler.
class SyncAutoSchedulerService {
  final SyncWorkerService workerService;
  final ConnectivityService connectivityService;
  final Duration interval;

  Timer? _timer;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _started = false;

  SyncAutoSchedulerService({
    required this.workerService,
    required this.connectivityService,
    this.interval = const Duration(minutes: 5),
  });

  bool get isStarted => _started;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    // App ochilganda bir marta.
    unawaited(runNow(reason: 'app_start'));

    // Internet qaytganda darhol sync.
    _connectivitySubscription =
        connectivityService.onConnectivityChanged.listen((online) {
      if (online) unawaited(runNow(reason: 'connectivity_restored'));
    });

    // Periodic sync.
    _timer = Timer.periodic(interval, (_) {
      unawaited(runNow(reason: 'periodic'));
    });
  }

  Future<void> runNow({String reason = 'manual'}) async {
    try {
      final online = connectivityService.isConnected;
      if (!online) {
        debugPrint('SyncAutoScheduler skipped ($reason): offline');
        return;
      }
      if (workerService.isRunning) {
        debugPrint('SyncAutoScheduler skipped ($reason): worker running');
        return;
      }
      debugPrint('SyncAutoScheduler run: $reason');
      await workerService.runOnce();
    } catch (e) {
      debugPrint('SyncAutoScheduler error: $e');
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _started = false;
  }

  void dispose() {
    stop();
  }
}
