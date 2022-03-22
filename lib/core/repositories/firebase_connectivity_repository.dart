import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseConnectivityRepository {
  FirebaseConnectivityRepository(
      {required this.firestoreInstance,
      required this.functionsInstance,
      required this.realtimeInstance,
      required this.token});

  final FirebaseFirestore firestoreInstance;
  final FirebaseFunctions functionsInstance;
  final FirebaseDatabase realtimeInstance;
  final String token;

  init() {
    final connectedDatabaseRef = FirebaseDatabase.instance.ref(".info/connected");
    final screenStatusDatabaseRef = realtimeInstance.ref('/status/' + token);

    connectedDatabaseRef.onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      if (!connected) return;

      screenStatusDatabaseRef.onDisconnect().set({
        'isOnline': false,
      }).then(
        (value) => screenStatusDatabaseRef.set(
          {'isOnline': true},
        ),
      );
    });
  }

  Future<void> notifyDevicesToOnlineStatus(
      bool isOnline, String message) async {
    HttpsCallable callable =
        functionsInstance.httpsCallable('notifyDevicesToOnlineStatus');
    final result = await callable.call(<String, dynamic>{
      'token': token,
      'isOnline': isOnline.toString(),
      'message': message
    });
    print("result: ${result.data}");
  }
}
