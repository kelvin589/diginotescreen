import 'package:diginotescreen/core/models/screen_model.dart';
import 'package:diginotescreen/core/repositories/firebase_pairing_repository.dart';
import 'package:diginotescreen/ui/shared/device_info.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../screen_matcher.dart';

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
        await firestoreInstance.collection("screens").doc(token).get();
    expect(snapshot.exists, true);

    final pairingInfo = snapshot.data();
    if (pairingInfo != null) {
      expect(pairingInfo["pairingCode"], pairingCode);
      expect(pairingInfo["width"], width);
      expect(pairingInfo["height"], height);
    }
  });

  test('Screen pairing info is received', () async {
    final Screen screen = Screen(
        pairingCode: "ABC123",
        paired: false,
        name: "name",
        userID: "userID",
        lastUpdated: DateTime.now(),
        screenToken: token,
        width: 100,
        height: 100);

    expect(
      pairingRepository.getStream(),
      emitsInOrder([
        null,
        ScreenMatcher(screen.toJson()),
      ]),
    );

    await Future.delayed(Duration.zero);
    await firestoreInstance
        .collection('screens')
        .doc(token)
        .withConverter<Screen>(
          fromFirestore: (snapshot, _) =>
              Screen.fromJson(snapshot.data()!),
          toFirestore: (screen, _) => screen.toJson(),
        )
        .set(screen);
  });
}
