import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FirebaseConnectivityRepository {
  FirebaseConnectivityRepository(
      {required this.firestoreInstance,
      required this.functionsInstance,
      required this.token});

  final FirebaseFirestore firestoreInstance;
  final FirebaseFunctions functionsInstance;
  final String token;

  Future<void> notifyDevicesToOnlineStatus(bool isOnline) async {
    HttpsCallable callable =
        functionsInstance.httpsCallable('notifyDevicesToOnlineStatus');
    final result = await callable.call(<String, dynamic>{
      'token': token,
      'isOnline': isOnline.toString(),
    });
    print("result: ${result.data}");
  }
}
