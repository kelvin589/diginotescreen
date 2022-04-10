import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/screen_model.dart';
import 'package:diginotescreen/core/repositories/firebase_pairing_repository.dart';
import 'package:diginotescreen/ui/shared/device_info.dart';
import 'package:flutter/material.dart';

/// A provider using the [FirebasePairingRepository].
/// 
/// Updates the pairing code, receives a stream of [Screen], and retrieves the token.
class FirebasePairingProvider extends ChangeNotifier {
  /// Creates a [FirebasePairingProvider] using a [FirebaseFirestore],
  /// for a given screen [token].
  /// 
  /// Initialises the [FirebasePairingRepository].
  FirebasePairingProvider(
      {required FirebaseFirestore firestoreInstance, String? token})
      : _pairingRepository = FirebasePairingRepository(
            firestoreInstance: firestoreInstance, token: token);

  /// The [FirebasePairingRepository] instance.
  final FirebasePairingRepository _pairingRepository;

  /// Initialises the [FirebasePairingProvider]. 
  Future<String?> init() async {
    return _pairingRepository.init();
  }

  /// Updates the [pairingCode] and [deviceInfo] for this screen.
  Future<void> addPairingCode(String pairingCode, DeviceInfo deviceInfo) async {
    await _pairingRepository.addPairingCode(pairingCode, deviceInfo);
  }

  /// Retrieves a stream of [Screen] information for this screen.
  Stream<Screen?> getStream() {
    return _pairingRepository.getStream();
  }

  /// Retrieves the screen token.
  String? getToken() => _pairingRepository.getToken();
}
