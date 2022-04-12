import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diginotescreen/core/repositories/firebase_connectivity_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// A provider using the [FirebaseConnectivityRepository].
/// 
/// Reports the connectivity status of the screen and notifies devices to this.
/// The [init] method must be called to initialise [FirebaseConnectivityProvider].
class FirebaseConnectivityProvider extends ChangeNotifier {
  /// A dummy constructor which initialises nothing.
  /// Required as there is no mock for [FirebaseFunctions].
  FirebaseConnectivityProvider.dummy() : isDummy = true;

  /// Indicates this instance of [FirebaseConnectivityProvider] as a dummy.
  /// 
  /// No functions work if [isDummy] is true.
  bool isDummy = false;

  /// Creates a [FirebaseConnectivityProvider] using a [FirebaseFirestore],
  /// [FirebaseDatabase] and [FirebaseFunctions] instance, for a given screen [token].
  /// 
  /// Initialises the [FirebaseConnectivityRepository].
  FirebaseConnectivityProvider(
      {required this.firestoreInstance,
      required this.functionsInstance,
      required this.realtimeInstance,
      required this.token})
      : _connectivityRepository = FirebaseConnectivityRepository(
            firestoreInstance: firestoreInstance,
            functionsInstance: functionsInstance,
            realtimeInstance: realtimeInstance,
            token: token);

  /// The [FirebaseFirestore] instance.
  late final FirebaseFirestore firestoreInstance;

  /// The [FirebaseFunctions] instance.
  late final FirebaseFunctions functionsInstance;

  /// The [FirebaseDatabase] instance.
  late final FirebaseDatabase realtimeInstance;

  /// The [FirebaseConnectivityRepository] instance.
  late final FirebaseConnectivityRepository _connectivityRepository;

  /// The screen token.
  late final String token;

  /// Initialises the [FirebaseConnectivityProvider]. 
  /// 
  /// Calls on [FirebaseConnectivityRepository.init];
  void init() {
    if (isDummy) return;
    
    _connectivityRepository.init();
  }

  /// Notifies devices to this screen's online status.
  Future<void> notifyDevicesToOnlineStatus(
      bool isOnline, String message) async {
    if (isDummy) return;

    await _connectivityRepository.notifyDevicesToOnlineStatus(
        isOnline, message);
    debugPrint("NOTIFYING DEVICES TO STATUS: $isOnline");
  }
}
