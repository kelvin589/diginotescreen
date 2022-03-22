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

  Future<void> notifyDevicesToOnlineStatus(bool isOnline, String message) async {
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
