import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/screen_pairing_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePairingRepository {
  final CollectionReference _pairingCodes =
      FirebaseFirestore.instance.collection('pairingCodes').withConverter<ScreenPairing>(
            fromFirestore: (snapshot, _) => ScreenPairing.fromJson(snapshot.data()!),
            toFirestore: (screenPairing, _) => screenPairing.toJson(),
          );

  Future<void> addPairingCode(String pairingCode) async {
    String? token = await FirebaseMessaging.instance.getToken();

    return _pairingCodes
        .doc(token)
        .set(ScreenPairing(pairingCode: pairingCode, paired: false))
        .then((value) => print("Added pairing code"))
        .catchError((error) => print("Failed to add pairing code: $error"));
  }
}
