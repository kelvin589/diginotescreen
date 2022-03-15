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
      required this.token,
      required this.duration})
      : _batteryRepository = FirebaseBatteryRepository(
            firestoreInstance: firestoreInstance, token: token);

  final FirebaseFirestore firestoreInstance;
  final FirebaseFunctions functionsInstance;
  final FirebaseBatteryRepository _batteryRepository;
  final Battery battery = Battery();
  final String token;

  Duration duration;
  Timer? timer;
  int lowBatteryThreshold = 30;
  // Seconds between low battery notifications
  Duration lowBatteryNotificationDelay = const Duration(seconds: 600);
  Timer? notificationTimer;

  Future<void> init() async {
    _listenToStream();
    await _startTimer();
  }

  Future<void> _startTimer() async {
    await _updateBatteryPercentage();
    timer = Timer.periodic(duration, _onTimerCallback);
  }

  void _listenToStream() {
    _batteryRepository.getStream().listen((screenInfo) {
      if (screenInfo != null) {
        lowBatteryThreshold = screenInfo.lowBatteryThreshold;
        lowBatteryNotificationDelay = Duration(seconds: screenInfo.lowBatteryNotificationDelay);
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  Future<void> _onTimerCallback(Timer timer) async {
    if (timer.isActive) {
      await _updateBatteryPercentage();
    }
  }

  Future<void> _updateBatteryPercentage() async {
    int newBatteryLevel = await battery.batteryLevel;
    await _batteryRepository.updateBatteryPercentage(newBatteryLevel);
    if (newBatteryLevel <= lowBatteryThreshold && notificationTimer == null) {
      await _notifyDevicesToLowBattery(newBatteryLevel);
      print("Notify to low battery");
      notificationTimer = Timer.periodic(lowBatteryNotificationDelay, (timer) {
        print("Cancel timer");
        timer.cancel();
        notificationTimer = null;
      });
    } else if (newBatteryLevel >= lowBatteryThreshold) {
      notificationTimer = null;
    }
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
