import 'package:clock/clock.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/models/screen_pairing_model.dart';
import 'package:diginotescreen/core/providers/firebase_pairing_provider.dart';
import 'package:diginotescreen/core/providers/firebase_preview_provider.dart';
import 'package:diginotescreen/main.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() async {
  const String token = "token";
  final Message message = Message(
    header: 'Header',
    message: 'Message',
    x: 0,
    y: 0,
    id: 'messageID',
    from: DateTime.now(),
    to: DateTime.now(),
    scheduled: false,
  );

  late FakeFirebaseFirestore firestoreInstance;
  late FirebasePairingProvider pairingProvider;
  late FirebasePreviewProvider previewProvider;

  setUp(() {
    firestoreInstance = FakeFirebaseFirestore();
    pairingProvider = FirebasePairingProvider(
        firestoreInstance: firestoreInstance, token: token);
    previewProvider =
        FirebasePreviewProvider(firestoreInstance: firestoreInstance);
  });

  Future<void> loadPairedApp(WidgetTester tester) async {
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

  Future<void> addMessage(Message message) async {
    await firestoreInstance
        .collection('messages')
        .doc(token)
        .collection('message')
        .doc(message.id)
        .withConverter<Message>(
          fromFirestore: (snapshot, _) {
            Map<String, dynamic> map = snapshot.data()!;
            map['id'] = snapshot.id;
            return Message.fromJson(map);
          },
          toFirestore: (message, _) => message.toJson(),
        )
        .set(Message(
            header: message.header,
            message: message.message,
            x: 0,
            y: 0,
            id: message.id,
            from: message.from,
            to: message.to,
            scheduled: message.scheduled));
  }

  void deleteMessage(String messageID) {
    previewProvider.deleteMessage(token, messageID);
  }

  group('Message Display', () {
    testWidgets('Display new message', (WidgetTester tester) async {
      await loadPairedApp(tester);

      await addMessage(message);

      await tester.idle();
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);

      expect(find.text("Header"), findsOneWidget);
      expect(find.text("Message"), findsOneWidget);
    });

    testWidgets('Update display after deleting a message',
        (WidgetTester tester) async {
      await loadPairedApp(tester);

      await addMessage(message);

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

  group('Message Scheduling', () {
    Message scheduledMessage(
        {required String message,
        required DateTime from,
        required DateTime to}) {
      return Message(
        header: 'Header',
        message: message,
        x: 0,
        y: 0,
        id: 'messageID',
        from: from,
        to: to,
        scheduled: true,
      );
    }

    testWidgets('Display a message now, indefinitely',
        (WidgetTester tester) async {
      await loadPairedApp(tester);
      await addMessage(
        scheduledMessage(
          message: 'now, indefinite',
          from: clock.now(),
          to: clock.now(),
        ),
      );

      await tester.idle();
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);

      expect(find.text('now, indefinite'), findsOneWidget);

      withClock(
        Clock.fixed(DateTime.now().add(const Duration(days: 100))),
        () async {
          await tester.idle();
          await tester.pump(Duration.zero);
          await tester.pump(Duration.zero);
          expect(find.text('now, indefinite'), findsOneWidget);
        },
      );
    });

    testWidgets('Display a message now, for a set period',
        (WidgetTester tester) async {
      await loadPairedApp(tester);
      await addMessage(
        scheduledMessage(
          message: 'now, set period',
          from: clock.now(),
          to: clock.now().add(const Duration(minutes: 5)),
        ),
      );

      await tester.idle();
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);

      expect(find.text('now, set period'), findsOneWidget);

      withClock(
        Clock.fixed(DateTime.now().add(const Duration(minutes: 5))),
        () async {
          await tester.idle();
          await tester.pump(const Duration(minutes: 5));
          await tester.pump(Duration.zero);
          expect(find.text('now, set period'), findsNothing);
        },
      );
    });

    testWidgets('Display a message in the future, indefinite',
        (WidgetTester tester) async {
      await loadPairedApp(tester);
      await addMessage(
        scheduledMessage(
          message: 'future, indefinite',
          from: clock.now().add(const Duration(minutes: 5)),
          to: clock.now().add(const Duration(minutes: 5)),
        ),
      );

      await tester.idle();
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);

      expect(find.text('future, indefinite'), findsNothing);

      // Displayed after 5 minutes
      await withClock(
        Clock.fixed(clock.now().add(const Duration(minutes: 5))),
        () async {
          await tester.idle();
          await tester.pumpAndSettle();
          await tester.pump(const Duration(minutes: 5));
          await tester.pump(Duration.zero);
          expect(find.text('future, indefinite'), findsOneWidget);
        },
      );

      // Displayed for 'indefinite'
      await withClock(
        Clock.fixed(clock.now().add(const Duration(days: 100))),
        () async {
          await tester.idle();
          await tester.pump(Duration.zero);
          await tester.pump(Duration.zero);
          expect(find.text('future, indefinite'), findsOneWidget);
        },
      );
    });

    testWidgets('Display a message in the future, for a set period',
        (WidgetTester tester) async {
      await loadPairedApp(tester);
      await addMessage(
        scheduledMessage(
          message: 'future, set period',
          from: clock.now().add(const Duration(minutes: 5)),
          to: clock.now().add(const Duration(minutes: 10)),
        ),
      );

      await tester.idle();
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);

      expect(find.text('future, set period'), findsNothing);

      await withClock(
        Clock.fixed(clock.now().add(const Duration(minutes: 5))),
        () async {
          await tester.idle();
          await tester.pump(const Duration(minutes: 5));
          await tester.pump(Duration.zero);
          expect(find.text('future, set period'), findsOneWidget);

          // Nested clock uses the adjusted clock.now()
          await withClock(
            Clock.fixed(
                clock.now().add(const Duration(minutes: 5, seconds: 1))),
            () async {
              await tester.idle();
              await tester.pump(const Duration(minutes: 5, seconds: 1));
              await tester.pump(Duration.zero);
              expect(find.text('future, set period'), findsNothing);
            },
          );
        },
      );
    });

    testWidgets(
        'Incorrect scheduling (from > to) displays the message now indefinitely',
        (WidgetTester tester) async {
      await loadPairedApp(tester);
      await addMessage(
        scheduledMessage(
          message: 'now, indefinite',
          from: clock.now().add(const Duration(minutes: 10)),
          to: clock.now().add(const Duration(minutes: 5)),
        ),
      );

      await tester.idle();
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);

      expect(find.text('now, indefinite'), findsOneWidget);

      withClock(
        Clock.fixed(DateTime.now().add(const Duration(days: 100))),
        () async {
          await tester.idle();
          await tester.pump(Duration.zero);
          await tester.pump(Duration.zero);
          expect(find.text('now, indefinite'), findsOneWidget);
        },
      );
    });
  });
}
