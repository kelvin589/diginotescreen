import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/screen_model.dart';
import 'package:diginotescreen/ui/shared/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePairingRepository {
  FirebasePairingRepository({required this.firestoreInstance, this.token});

  final FirebaseFirestore firestoreInstance;
  late FirebaseMessaging firebaseMessaging;

  String? token;
  // No mock for FCM. Instead, allow token to be passed in.
  Future<String?> init() async {
    if (token == null) {
      firebaseMessaging = FirebaseMessaging.instance;
      String? retrievedToken = await firebaseMessaging.getToken();
      token = retrievedToken;
    }
  }

  String? getToken() => token;

  Future<void> addPairingCode(String pairingCode, DeviceInfo deviceInfo) async {
    return firestoreInstance
        .collection('screens')
        .withConverter<Screen>(
          fromFirestore: (snapshot, _) =>
              Screen.fromJson(snapshot.data()!),
          toFirestore: (screen, _) => screen.toJson(),
        )
        .doc(token)
        .set(
            Screen(
              pairingCode: pairingCode,
              paired: false,
              lastUpdated: DateTime.now(),
              name: '',
              screenToken: token!,
              userID: '',
              width: deviceInfo.width,
              height: deviceInfo.safeHeight,
            ),
            SetOptions(merge: true))
        .then((value) => print("Added pairing code"))
        .catchError((error) => print("Failed to add pairing code: $error"));
  }

  Stream<Screen?> getStream() {
    return firestoreInstance
        .collection('screens')
        .doc(token)
        .withConverter<Screen>(
          fromFirestore: (snapshot, _) =>
              Screen.fromJson(snapshot.data()!),
          toFirestore: (screen, _) => screen.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.data());
  }
}
