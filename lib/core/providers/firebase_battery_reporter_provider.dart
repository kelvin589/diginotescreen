import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diginotescreen/core/repositories/firebase_battery_reporter_repository.dart';
import 'package:flutter/material.dart';

/// A provider using the [FirebaseBatteryReporterRepository].
/// 
/// Reports the battery percentage and notifies devices to low battery.
/// The [init] method must be called to initialise [FirebaseBatteryReporterProvider].
class FirebaseBatteryReporterProvider extends ChangeNotifier {
  /// A dummy constructor which initialises nothing.
  /// Required as there is no mock for [FirebaseFunctions].
  FirebaseBatteryReporterProvider.dummy() : isDummy = true;

  /// Indicates this instance of [FirebaseBatteryReporterProvider] as a dummy.
  /// 
  /// No functions work if [isDummy] is true.
  bool isDummy = false;

  /// Creates a [FirebaseBatteryReporterProvider] using a [FirebaseFirestore] and
  /// [FirebaseFunctions] instance, for a given screen [token].
  /// 
  /// Initialises the [FirebaseBatteryReporterRepository].
  FirebaseBatteryReporterProvider(
      {required this.firestoreInstance,
      required this.functionsInstance,
      required this.token})
      : _batteryRepository = FirebaseBatteryReporterRepository(
            firestoreInstance: firestoreInstance,  functionsInstance: functionsInstance, token: token);

  /// The [FirebaseFirestore] instance.
  late final FirebaseFirestore firestoreInstance;

  /// The [FirebaseFunctions] instance.
  late final FirebaseFunctions functionsInstance;

  /// The [FirebaseBatteryReporterRepository] instance.
  late final FirebaseBatteryReporterRepository _batteryRepository;

  /// The [Battery] instance.
  final Battery battery = Battery();

  /// The screen token.
  late final String token;

  /// The delay between updating the battery level of this screen.
  int _batteryReportingDelay = 60;

  /// The delay between notifications to 'low battery'.
  int _lowBatteryNotificationDelay = 600;

  /// The threshold at which a 'low battery' notification is sent.
  int _lowBatteryThreshold = 30;

  /// The timer which updates the battery level of this screen.
  /// 
  /// Calls on [FirebaseBatteryReporterRepository.updateBatteryPercentage] 
  /// every [_batteryReportingDelay] amount of seconds.
  Timer? _updateBatteryTimer;

  /// The timer which notifies devices to 'low battery'.
  /// 
  /// Calls on [FirebaseBatteryReporterRepository.notifyDevicesToLowBattery] 
  /// every [_lowBatteryNotificationDelay] amount of seconds as long as
  /// [Battery.batteryLevel] is below [_lowBatteryThreshold].
  Timer? _notificationTimer;

  /// Initialises the [FirebaseBatteryReporterProvider]
  /// 
  /// Starting the [_updateBatteryTimer] and [_listenToStream] of the [ScreenInfo].
  Future<void> init() async {
    if (isDummy) return;

    await _startUpdateBatteryTimer();
    _listenToStream();
  }

  /// Listens to the stream of this screen's [ScreenInfo]. Battery notification
  /// parameters are updated only if changes are found. If changes are found,
  /// timers must be reset using [_resetTimers] so that changes are updated.
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

  /// Resets the timers to ensure the timer parameters are updated accordingly.
  void _resetTimers() {
    if (isDummy) return;

    _stopUpdateBatteryTimer();
    _stopNotificationTimer();
    _startUpdateBatteryTimer();
    // The notification timer does not need to be started as 
    // that will be done automatically.
  }

  /// Starts the timer to update the battery level. 
  Future<void> _startUpdateBatteryTimer() async {
    if (isDummy) return;

    // Must be called at least once, otherwise it will not be called
    // until the interval is reached.
    await _updateBatteryPercentage();
    _updateBatteryTimer =
        Timer.periodic(Duration(seconds: _batteryReportingDelay), _onTimerCallback);
  }

  /// Stops the timer updating the battery level.
  void _stopUpdateBatteryTimer() {
    if (isDummy) return;

    debugPrint("Cancel update timer");
    _updateBatteryTimer?.cancel();
    _updateBatteryTimer = null;
  }

  /// The callback is called when the timer hits its interval. 
  /// Changes are written to Firebase in the [_updateBatteryPercentage] method.
  Future<void> _onTimerCallback(Timer timer) async {
    if (isDummy) return;

    if (timer.isActive) {
      await _updateBatteryPercentage();
    }
  }

  /// Writes the current battery level to Firebase and
  /// [FirebaseBatteryReporterRepository.notifyDevicesToLowBattery] as necessary. 
  Future<void> _updateBatteryPercentage() async {
    if (isDummy) return;

    // Get the current battery level.
    int newBatteryLevel = await battery.batteryLevel;
    // Update the battery level.
    await _batteryRepository.updateBatteryPercentage(newBatteryLevel);

    // If we are below threshold and we haven't notified yet.
    if (newBatteryLevel <= _lowBatteryThreshold && _notificationTimer == null) {
      debugPrint("Notify to low battery");
      await _batteryRepository.notifyDevicesToLowBattery(newBatteryLevel);
      // Start the notification timer to prevent further notifications
      // until the delay is met.
      _startNotificationTimer();
    // The battery level is above threshold so we don't need to notify.
    } else if (newBatteryLevel >= _lowBatteryThreshold) {
      _notificationTimer = null;
    }
  }

  /// Starts the notification timer to notify devices to 'low battery'.
  void _startNotificationTimer() {
    if (isDummy) return;

    _notificationTimer = Timer.periodic(Duration(seconds: _lowBatteryNotificationDelay), (timer) {
      _stopNotificationTimer();
    });
  }

  /// Stops the notification timer
  void _stopNotificationTimer() {
    if (isDummy) return;

    debugPrint("Cancel notification timer");
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }
}
