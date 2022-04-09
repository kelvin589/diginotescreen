import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diginotescreen/core/repositories/firebase_connectivity_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/*
Online connectivity checking based on network connection, using firebase, would require
scheduled cloud functions which are billable. 
*/

class FirebaseConnectivityProvider extends ChangeNotifier {
  FirebaseConnectivityProvider.dummy() : isDummy = true;

  bool isDummy = false;

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

  late final FirebaseFirestore firestoreInstance;
  late final FirebaseFunctions functionsInstance;
  late final FirebaseDatabase realtimeInstance;
  late final FirebaseConnectivityRepository _connectivityRepository;
  late final String token;

  void init() {
    if (isDummy) return;
    
    _connectivityRepository.init();
  }

  Future<void> notifyDevicesToOnlineStatus(
      bool isOnline, String message) async {
    if (isDummy) return;

    await _connectivityRepository.notifyDevicesToOnlineStatus(
        isOnline, message);
    debugPrint("NOTIFYING DEVICES TO STATUS: $isOnline");
  }
}
