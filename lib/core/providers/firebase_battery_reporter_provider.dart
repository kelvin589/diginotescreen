import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diginotescreen/core/repositories/firebase_battery_reporter_repository.dart';
import 'package:flutter/material.dart';

class FirebaseBatteryReporterProvider extends ChangeNotifier {
  FirebaseBatteryReporterProvider.dummy() : isDummy = true;

  bool isDummy = false;

  FirebaseBatteryReporterProvider(
      {required this.firestoreInstance,
      required this.functionsInstance,
      required this.token})
      : _batteryRepository = FirebaseBatteryReporterRepository(
            firestoreInstance: firestoreInstance,  functionsInstance: functionsInstance, token: token);

  late final FirebaseFirestore firestoreInstance;
  late final FirebaseFunctions functionsInstance;
  late final FirebaseBatteryReporterRepository _batteryRepository;
  final Battery battery = Battery();
  late final String token;

  int _batteryReportingDelay = 60;
  int _lowBatteryNotificationDelay = 600;
  int _lowBatteryThreshold = 30;

  Timer? _updateBatteryTimer;
  // Seconds between low battery notifications
  Timer? _notificationTimer;

  Future<void> init() async {
    if (isDummy) return;

    await _startUpdateBatteryTimer();
    _listenToStream();
  }

  void _listenToStream() {
    if (isDummy) return;

    _batteryRepository.getStream().listen(
      (screenInfo) {
        if (screenInfo == null) {
          return;
        }
        if (_lowBatteryThreshold != screenInfo.lowBatteryThreshold) {
          _lowBatteryThreshold = screenInfo.lowBatteryThreshold;
          _resetTimers();
        }
        if (_lowBatteryNotificationDelay != screenInfo.lowBatteryNotificationDelay) {
           _lowBatteryNotificationDelay = screenInfo.lowBatteryNotificationDelay;
           _resetTimers();
        }
        if (_batteryReportingDelay != screenInfo.batteryReportingDelay) {
           _batteryReportingDelay = screenInfo.batteryReportingDelay;
           _resetTimers();
        }
      },
    );
  }

  void _resetTimers() {
    if (isDummy) return;

    _stopUpdateBatteryTimer();
    _stopNotificationTimer();
    _startUpdateBatteryTimer();
  }

  Future<void> _startUpdateBatteryTimer() async {
    if (isDummy) return;

    await _updateBatteryPercentage();
    _updateBatteryTimer =
        Timer.periodic(Duration(seconds: _batteryReportingDelay), _onTimerCallback);
  }

  void _stopUpdateBatteryTimer() {
    if (isDummy) return;

    debugPrint("Cancel update timer");
    _updateBatteryTimer?.cancel();
    _updateBatteryTimer = null;
  }

  Future<void> _onTimerCallback(Timer timer) async {
    if (isDummy) return;

    if (timer.isActive) {
      await _updateBatteryPercentage();
    }
  }

  Future<void> _updateBatteryPercentage() async {
    if (isDummy) return;

    int newBatteryLevel = await battery.batteryLevel;
    await _batteryRepository.updateBatteryPercentage(newBatteryLevel);
    if (newBatteryLevel <= _lowBatteryThreshold && _notificationTimer == null) {
      debugPrint("Notify to low battery");
      await _batteryRepository.notifyDevicesToLowBattery(newBatteryLevel);
      _startNotificationTimer();
    } else if (newBatteryLevel >= _lowBatteryThreshold) {
      _notificationTimer = null;
    }
  }

  void _startNotificationTimer() {
    if (isDummy) return;

    _notificationTimer = Timer.periodic(Duration(seconds: _lowBatteryNotificationDelay), (timer) {
      _stopNotificationTimer();
    });
  }

  void _stopNotificationTimer() {
    if (isDummy) return;

    debugPrint("Cancel notification timer");
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }
}
