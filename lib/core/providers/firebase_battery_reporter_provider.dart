import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diginotescreen/core/repositories/firebase_battery_repository.dart';
import 'package:flutter/material.dart';

class FirebaseBatteryReporterProvider extends ChangeNotifier {
  FirebaseBatteryReporterProvider(
      {required this.firestoreInstance,
      required this.functionsInstance,
      required this.token})
      : _batteryRepository = FirebaseBatteryRepository(
            firestoreInstance: firestoreInstance, token: token);

  final FirebaseFirestore firestoreInstance;
  final FirebaseFunctions functionsInstance;
  final FirebaseBatteryRepository _batteryRepository;
  final Battery battery = Battery();
  final String token;

  // TODO: Add configurable update period
  int _batteryReportingDelay = 1;
  int _lowBatteryNotificationDelay = 600;
  int _lowBatteryThreshold = 30;

  Timer? _updateBatteryTimer;
  // Seconds between low battery notifications
  Timer? _notificationTimer;

  Future<void> init() async {
    _listenToStream();
    await _startUpdateBatteryTimer();
  }

  void _listenToStream() {
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
      },
    );
  }

  void _resetTimers() {
    _stopUpdateBatteryTimer();
    _stopNotificationTimer();
    _startUpdateBatteryTimer();
  }

  Future<void> _startUpdateBatteryTimer() async {
    await _updateBatteryPercentage();
    _updateBatteryTimer =
        Timer.periodic(Duration(seconds: _batteryReportingDelay), _onTimerCallback);
  }

  void _stopUpdateBatteryTimer() {
    print("Cancel update timer");
    _updateBatteryTimer?.cancel();
    _updateBatteryTimer = null;
  }

  Future<void> _onTimerCallback(Timer timer) async {
    if (timer.isActive) {
      await _updateBatteryPercentage();
    }
  }

  Future<void> _updateBatteryPercentage() async {
    int newBatteryLevel = await battery.batteryLevel;
    await _batteryRepository.updateBatteryPercentage(newBatteryLevel);
    if (newBatteryLevel <= _lowBatteryThreshold && _notificationTimer == null) {
      print("Notify to low battery");
      await _notifyDevicesToLowBattery(newBatteryLevel);
      _startNotificationTimer();
    } else if (newBatteryLevel >= _lowBatteryThreshold) {
      _notificationTimer = null;
    }
  }

  void _startNotificationTimer() {
    _notificationTimer = Timer.periodic(Duration(seconds: _lowBatteryNotificationDelay), (timer) {
      _stopNotificationTimer();
    });
  }

  void _stopNotificationTimer() {
    print("Cancel notification timer");
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  Future<void> _notifyDevicesToLowBattery(int batteryLevel) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('notifyDevicesToLowBattery');
    final result = await callable.call(<String, dynamic>{
      'token': token,
      'batteryLevel': batteryLevel,
    });
    print("result: ${result.data}");
  }
}
