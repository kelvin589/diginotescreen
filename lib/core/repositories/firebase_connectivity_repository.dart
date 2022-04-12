import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// The repository to notify devices to this screen's connection status.
///
/// The [init] method must be called to initialise [FirebaseConnectivityRepository].
class FirebaseConnectivityRepository {
  /// Creates a [FirebaseConnectivityRepository] using a [FirebaseFirestore],
  /// [FirebaseFunctions] and [FirebaseDatabase] instance, for a given screen [token].
  FirebaseConnectivityRepository({
    required this.firestoreInstance,
    required this.functionsInstance,
    required this.realtimeInstance,
    required this.token,
  });

  /// The [FirebaseFirestore] instance.
  final FirebaseFirestore firestoreInstance;

  /// The [FirebaseFunctions] instance.
  final FirebaseFunctions functionsInstance;

  /// The [FirebaseDatabase] instance.
  final FirebaseDatabase realtimeInstance;

  /// The screen token.
  final String token;

  /// Initialises the [FirebaseConnectivityRepository] by adding a listener
  /// to the "/.info/connected" location provided by Firebase Realtime Database,
  /// and setting "isOnline" status in the [DatabaseReference.onDisconnect] event.
  init() {
    // Special location which returns true if connected, false if disconnected,
    final connectedDatabaseRef = realtimeInstance.ref(".info/connected");
    final screenStatusDatabaseRef = realtimeInstance.ref('/status/' + token);

    // onDisconnect operations are triggered once so we must re-establish the
    // onDisconnect operation each time.
    connectedDatabaseRef.onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      // We're not connected so do nothing
      if (!connected) return;

      // onDisconnect() is triggered once client disconnects.
      // onDisconnect().set() future returns when server acknowledges the request.
      screenStatusDatabaseRef.onDisconnect().set({
        'isOnline': false,
      }).then(
        (value) => screenStatusDatabaseRef.set(
          {'isOnline': true},
        ),
      );
    });
  }

  /// Calls a cloud function to notify devices, associated with this screen's
  /// userID, to the online status.
  ///
  /// The [message] contains the body of the notification, along with the 
  /// [isOnline] status of this screen in the notification title.
  Future<void> notifyDevicesToOnlineStatus(
      bool isOnline, String message) async {
    // Call the cloud function and await the result.
    HttpsCallable callable =
        functionsInstance.httpsCallable('notifyDevicesToOnlineStatus');
    final result = await callable.call(<String, dynamic>{
      'token': token,
      'isOnline': isOnline.toString(),
      'message': message
    });
    debugPrint("result: ${result.data}");
  }
}
