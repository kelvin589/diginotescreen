import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/repositories/firebase_battery_repository.dart';
import 'package:flutter/material.dart';

class BatteryReporterProvider extends ChangeNotifier {
  BatteryReporterProvider(
      {required this.firestoreInstance,
      required this.token,
      required this.duration})
      : _batteryRepository = FirebaseBatteryRepository(
            firestoreInstance: firestoreInstance, token: token);

  Duration duration;
  Timer? timer;
  final Battery battery = Battery();
  final String token;
  final FirebaseFirestore firestoreInstance;
  final FirebaseBatteryRepository _batteryRepository;

  Future<void> startTimer() async {
    await _updateBatteryPercentage();
    timer = Timer.periodic(duration, _onTimerCallback);
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
    await _batteryRepository.updateBatteryPercentage(await battery.batteryLevel);
  }
}
