import 'dart:math';

import 'package:diginotescreen/core/repositories/firebase_pairing_repository.dart';
import 'package:diginotescreen/firebase_options.dart';
import 'package:diginotescreen/ui/shared/device_info.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  const String token = "token";
  late FakeFirebaseFirestore firestoreInstance;
  late FirebasePairingRepository pairingRepository;

  setUp(() {
    firestoreInstance = FakeFirebaseFirestore();
    pairingRepository = FirebasePairingRepository(
        firestoreInstance: firestoreInstance, token: token);
  });

  test('Pairing code and device info are added', () async {
    const String pairingCode = "A12BCE";
    const double width = 100;
    const double height = 100;
    const EdgeInsets viewPadding = EdgeInsets.zero;
    DeviceInfo deviceInfo = DeviceInfo.withValues(
        width: width, height: height, viewPadding: viewPadding);
    pairingRepository.addPairingCode(pairingCode, deviceInfo);

    final snapshot =
        await firestoreInstance.collection("pairingCodes").doc(token).get();
    expect(snapshot.exists, true);
    
    final pairingInfo = snapshot.data();
    if (pairingInfo != null) {
      expect(pairingInfo["pairingCode"], pairingCode);
      expect(pairingInfo["width"], width);
      expect(pairingInfo["height"], height);
    }
  });
}
