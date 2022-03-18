import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diginotescreen/core/repositories/firebase_connectivity_repository.dart';
import 'package:flutter/material.dart';

class FirebaseConnectivityProvider extends ChangeNotifier {
  FirebaseConnectivityProvider(
      {required this.firestoreInstance,
      required this.functionsInstance,
      required this.token})
      : _connectivityRepository = FirebaseConnectivityRepository(
            firestoreInstance: firestoreInstance,
            functionsInstance: functionsInstance,
            token: token);

  final FirebaseFirestore firestoreInstance;
  final FirebaseFunctions functionsInstance;
  final FirebaseConnectivityRepository _connectivityRepository;
  final String token;

  Future<void> notifyDevicesToOnlineStatus(bool isOnline) async {
    await _connectivityRepository.notifyDevicesToOnlineStatus(isOnline);
  }
}
