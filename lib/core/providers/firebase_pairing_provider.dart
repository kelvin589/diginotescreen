import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/screen_model.dart';
import 'package:diginotescreen/core/repositories/firebase_pairing_repository.dart';
import 'package:diginotescreen/ui/shared/device_info.dart';
import 'package:flutter/material.dart';

class FirebasePairingProvider extends ChangeNotifier {
  FirebasePairingProvider(
      {required FirebaseFirestore firestoreInstance, String? token})
      : _pairingRepository = FirebasePairingRepository(
            firestoreInstance: firestoreInstance, token: token);

  final FirebasePairingRepository _pairingRepository;

  Future<String?> init() async {
    await _pairingRepository.init();
  }

  Future<void> addPairingCode(String pairingCode, DeviceInfo deviceInfo) async {
    await _pairingRepository.addPairingCode(pairingCode, deviceInfo);
  }

  Stream<Screen?> getStream() {
    return _pairingRepository.getStream();
  }

  String? getToken() => _pairingRepository.getToken();
}
