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

  final FirebaseFirestore firestoreInstance;
  final FirebaseFunctions functionsInstance;
  final FirebaseDatabase realtimeInstance;
  final FirebaseConnectivityRepository _connectivityRepository;
  final String token;

  void init() {
    _connectivityRepository.init();
  }

  Future<void> notifyDevicesToOnlineStatus(bool isOnline, String message) async {
    await _connectivityRepository.notifyDevicesToOnlineStatus(isOnline, message);
    print("NOTIFYING DEVICES TO STATUS: $isOnline");
  }
}
