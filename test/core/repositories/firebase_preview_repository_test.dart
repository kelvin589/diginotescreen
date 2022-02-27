import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/models/screen_pairing_model.dart';
import 'package:diginotescreen/core/providers/firebase_pairing_provider.dart';
import 'package:diginotescreen/core/providers/firebase_preview_provider.dart';
import 'package:diginotescreen/main.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() async {
  group('Message Display', () {
    const String token = "token";
    FakeFirebaseFirestore firestoreInstance = FakeFirebaseFirestore();
    FirebasePairingProvider pairingProvider;
    late FirebasePreviewProvider previewProvider;

    Future<void> loadApp(WidgetTester tester) async {
      pairingProvider = FirebasePairingProvider(
          firestoreInstance: firestoreInstance, token: token);
      previewProvider =
          FirebasePreviewProvider(firestoreInstance: firestoreInstance);
      // Load app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => pairingProvider),
            ChangeNotifierProvider(create: (context) => previewProvider),
          ],
          child: const MyApp(),
        ),
      );

      // Pair screen
      await firestoreInstance
          .collection('pairingCodes')
          .withConverter<ScreenPairing>(
            fromFirestore: (snapshot, _) =>
                ScreenPairing.fromJson(snapshot.data()!),
            toFirestore: (screenPairing, _) => screenPairing.toJson(),
          )
          .doc(token)
          .set(
            ScreenPairing(
              pairingCode: '',
              paired: true,
              lastUpdated: DateTime.now(),
              name: '',
              screenToken: token,
              userID: '',
              width: 0,
              height: 0,
            ),
          );
    }

    Future<void> addMessage(
        {required String messageID,
        required String header,
        required String message}) async {
      await firestoreInstance
          .collection('messages')
          .doc(token)
          .collection('message')
          .doc(messageID)
          .withConverter<Message>(
            fromFirestore: (snapshot, _) {
              Map<String, dynamic> map = snapshot.data()!;
              map['id'] = snapshot.id;
              return Message.fromJson(map);
            },
            toFirestore: (message, _) => message.toJson(),
          )
          .set(Message(
              header: header,
              message: message,
              x: 0,
              y: 0,
              id: messageID,
              from: DateTime.now(),
              to: DateTime.now(),
              scheduled: false));
    }

    void deleteMessage(String messageID) {
      previewProvider.deleteMessage(token, messageID);
    }

    testWidgets('Display new message', (WidgetTester tester) async {
      await loadApp(tester);

      await addMessage(
          messageID: 'messageID', header: 'Header', message: 'Message');

      await tester.idle();
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);

      expect(find.text("Header"), findsOneWidget);
      expect(find.text("Message"), findsOneWidget);
    });

    testWidgets('Update display after deleting a message',
        (WidgetTester tester) async {
      await loadApp(tester);

      await addMessage(
          messageID: 'messageID', header: 'Header', message: 'Message');

      await tester.idle();
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);

      expect(find.text("Header"), findsOneWidget);
      expect(find.text("Message"), findsOneWidget);

      deleteMessage('messageID');
      await tester.idle();
      await tester.pump(Duration.zero);

      expect(find.text("Header"), findsNothing);
      expect(find.text("Message"), findsNothing);
    });
  });

  group('Message Scheduling', () {});
}
