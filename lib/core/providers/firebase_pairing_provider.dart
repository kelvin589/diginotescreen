import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/screen_pairing_model.dart';
import 'package:diginotescreen/core/repositories/firebase_pairing_repository.dart';
import 'package:flutter/material.dart';

class FirebasePairingProvider extends ChangeNotifier {
  final FirebasePairingRepository _pairingRepository =
      FirebasePairingRepository();

  Future<void> addPairingCode(String pairingCode) async {
    await _pairingRepository.addPairingCode(pairingCode);
  }

  Stream<DocumentSnapshot<ScreenPairing>> getStream() {
    return _pairingRepository.getStream();
  }
}
