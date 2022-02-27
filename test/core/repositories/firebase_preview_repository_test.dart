import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/repositories/firebase_preview_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestoreInstance;
  late FirebasePreviewRepository previewRepository;
  const String token = "token";

  setUp(() {
    firestoreInstance = FakeFirebaseFirestore();
    previewRepository =
        FirebasePreviewRepository(firestoreInstance: firestoreInstance);
  });

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

  test('Delete a message', () async {
    await addMessage(
        messageID: 'messageID', header: 'Header', message: 'Message');
    final messages = await firestoreInstance
        .collection('messages')
        .doc(token)
        .collection('message')
        .get();
    previewRepository.deleteMessage(token, 'messageID');
    expect(firestoreInstance.hasSavedDocument('messages/token/message/messageID'), false);
  });
}
