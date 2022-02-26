import 'package:diginotescreen/core/models/screen_pairing_model.dart';
import 'package:diginotescreen/core/repositories/firebase_pairing_repository.dart';
import 'package:diginotescreen/ui/shared/device_info.dart';
import 'package:flutter/material.dart';

class FirebasePairingProvider extends ChangeNotifier {
  final FirebasePairingRepository _pairingRepository =
      FirebasePairingRepository();

  Future<String?> init() async {
    await _pairingRepository.init();
  }

  Future<void> addPairingCode(String pairingCode, DeviceInfo deviceInfo) async {
    await _pairingRepository.addPairingCode(pairingCode, deviceInfo);
  }

  Stream<ScreenPairing?> getStream() {
    return _pairingRepository.getStream();
  }

  String? getToken() => _pairingRepository.getToken();
}
