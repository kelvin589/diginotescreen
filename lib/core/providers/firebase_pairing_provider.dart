import 'package:diginotescreen/core/repositories/firebase_pairing_repository.dart';
import 'package:flutter/material.dart';

class FirebasePairingProvider extends ChangeNotifier {
  final FirebasePairingRepository _pairingRepository =
      FirebasePairingRepository();

  void addPairingCode(String pairingCode) async {
    await _pairingRepository.addPairingCode(pairingCode);
  }
}
