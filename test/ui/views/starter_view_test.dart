import 'package:diginotescreen/core/providers/firebase_pairing_provider.dart';
import 'package:diginotescreen/main.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() async {
  late FakeFirebaseFirestore firestoreInstance;
  // The device token
  const String token = "token";

  setUp(() {
    firestoreInstance = FakeFirebaseFirestore();
  });

  Future<void> loadApp(WidgetTester tester, String token) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<FirebasePairingProvider>(
        child: const MyApp(),
        create: (context) => FirebasePairingProvider(
            firestoreInstance: firestoreInstance, token: token),
      ),
    );
  }

  group('Pairing', () {
    testWidgets('Update pairing code, for an unpaired screen, every 10 minutes',
        (WidgetTester tester) async {
      // 10 minute duration
      const codeRefreshRate = Duration(seconds: 600);

      await loadApp(tester, token);
      await tester.pump(const Duration(seconds: 1));

      // Find text matching regex expected of the format of pairing code
      final pairingCodeFinder = find.textContaining(RegExp(r'^[A-Z0-9]{6}$'));

      // ----Test the pairing code before---- //
      expect(pairingCodeFinder, findsOneWidget);
      String? codeBefore = (tester.firstWidget(pairingCodeFinder) as Text).data;

      final snapshotBefore =
          await firestoreInstance.collection("screens").doc(token).get();
      expect(snapshotBefore.get("pairingCode"), codeBefore);

      // ----Test the pairing code after 10 minutes---- //
      await tester.pump(codeRefreshRate);

      expect(pairingCodeFinder, findsOneWidget);
      String? codeAfter = (tester.firstWidget(pairingCodeFinder) as Text).data;

      final snapshotAfter =
          await firestoreInstance.collection("screens").doc(token).get();
      expect(snapshotAfter.get("pairingCode"), codeAfter);
      expect(snapshotAfter.get("pairingCode") != codeBefore, true);
    });
  });
}
