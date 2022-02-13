import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePairingRepository {
  final CollectionReference _pairingCodes =
      FirebaseFirestore.instance.collection('pairingCodes');

  Future<void> addPairingCode(String pairingCode) async {
    String? token = await FirebaseMessaging.instance.getToken();

    return _pairingCodes
        .doc(token)
        .set({
          'pairingCode': pairingCode,
        })
        .then((value) => print("Added pairing code"))
        .catchError((error) => print("Failed to add pairing code: $error"));
  }
}
