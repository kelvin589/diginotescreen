import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/messages_model.dart';

class FirebasePreviewRepository {
  FirebasePreviewRepository({required this.firestoreInstance});

  final FirebaseFirestore firestoreInstance;

  Stream<Iterable<Message>> getMessages(String screenToken) {
    return firestoreInstance
        .collection('messages')
        .doc(screenToken)
        .collection('message')
        .withConverter<Message>(
          fromFirestore: (snapshot, _) {
            Map<String, dynamic> map = snapshot.data()!;
            map['id'] = snapshot.id;
            return Message.fromJson(map);
          },
          toFirestore: (message, _) => message.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => e.data()));
  }

  void deleteMessage(String screenToken, String messageID) {
    firestoreInstance
        .collection('messages')
        .doc(screenToken)
        .collection('message')
        .doc(messageID)
        .delete()
        .then((value) => print("Deleted message"))
        .onError(
            (error, stackTrace) => print("unable to delete message: $error"));
  }
}
