import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

  Future<String> getUsersEmail(String screenToken) async {
    final usersSnapshot = await firestoreInstance
      .collection('screens')
      .doc(screenToken)
      .get();
    final userDoc = usersSnapshot.data();
    String userID = "";
    if (userDoc != null) {
      userID = userDoc["userID"];
    }
  
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('getUsersEmail');
    final result = await callable.call(<String, dynamic>{
      'userID': userID,
    });
    final String? email = result.data;
    return email ?? "";
  }
}
