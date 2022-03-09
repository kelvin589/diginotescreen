import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/repositories/firebase_preview_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../document_snapshot_matcher.dart';
import '../../message_matcher.dart';
import '../../query_snapshot_matcher.dart';

void main() {
  late FakeFirebaseFirestore firestoreInstance;
  late FirebasePreviewRepository previewRepository;
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
    fontFamily: "Roboto",
    fontSize: 12,
    backgrondColour: 4294961979,
    foregroundColour: 4278190080,
    width: 100,
    height: 100,
  );

  setUp(() {
    firestoreInstance = FakeFirebaseFirestore();
    previewRepository =
        FirebasePreviewRepository(firestoreInstance: firestoreInstance);
  });

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
        .set(message);
  }

  test('Delete a message', () async {
    await addMessage(message);
    expect(
        firestoreInstance.hasSavedDocument('messages/$token/message/messageID'),
        true);

    previewRepository.deleteMessage(token, 'messageID');
    final messages = await firestoreInstance
        .collection('messages')
        .doc(token)
        .collection('message')
        .get();

    expect(messages.docs.isEmpty, true);
    expect(
        firestoreInstance.hasSavedDocument('messages/$token/message/messageID'),
        false);
  });

  test('Get a stream of message snapshots', () async {
    expect(
      previewRepository.getMessages(token),
      emitsInOrder([
        [],
        [MessageMatcher(message.toJson())],
      ]),
    );

    await Future.delayed(Duration.zero);
    await addMessage(message);
  });
}
