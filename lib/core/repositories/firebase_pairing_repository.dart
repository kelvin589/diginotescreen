import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/screen_pairing_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePairingRepository {
  final CollectionReference _pairingCodes = FirebaseFirestore.instance
      .collection('pairingCodes')
      .withConverter<ScreenPairing>(
        fromFirestore: (snapshot, _) =>
            ScreenPairing.fromJson(snapshot.data()!),
        toFirestore: (screenPairing, _) => screenPairing.toJson(),
      );
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  String? token;
  Future<String?> init() async {
    String? retrievedToken = await firebaseMessaging.getToken();
    token = retrievedToken;
  }

  Future<void> addPairingCode(String pairingCode) async {
    return _pairingCodes
        .doc(token)
        .set(
            ScreenPairing(
              pairingCode: pairingCode,
              paired: false,
              lastUpdated: DateTime.now(),
              name: '',
              screenToken: '',
              userID: '',
            ),
            SetOptions(merge: true))
        .then((value) => print("Added pairing code"))
        .catchError((error) => print("Failed to add pairing code: $error"));
  }

  Stream<ScreenPairing?> getStream() {
    return FirebaseFirestore.instance
        .collection('pairingCodes')
        .doc(token)
        .withConverter<ScreenPairing>(
          fromFirestore: (snapshot, _) =>
              ScreenPairing.fromJson(snapshot.data()!),
          toFirestore: (screenPairing, _) => screenPairing.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.data());
  }
}
