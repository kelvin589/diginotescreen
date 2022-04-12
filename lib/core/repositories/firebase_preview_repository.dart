import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:flutter/material.dart';

/// The repository to access functionality related to the preview.
///
/// Retrieving and deleting messages, and retriving the user's email for the QR code.
class FirebasePreviewRepository {
  /// Creates a [FirebasePreviewRepository] using a [FirebaseFirestore] instance.
  FirebasePreviewRepository({required this.firestoreInstance});

  /// The [FirebaseFirestore] instance.
  final FirebaseFirestore firestoreInstance;

  /// Retrieve a stream of [Message] for the given [screenToken].
  Stream<Iterable<Message>> getMessages(String screenToken) {
    return firestoreInstance
        .collection('messages')
        .doc(screenToken)
        .collection('message')
        .withConverter<Message>(
          fromFirestore: (snapshot, _) {
            Map<String, dynamic> map = snapshot.data()!;
            // The id is required so that it can be referenced to.
            map['id'] = snapshot.id;
            return Message.fromJson(map);
          },
          toFirestore: (message, _) => message.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => e.data()));
  }

  /// Delete the [Message] with [messageID] for the given [screenToken].
  void deleteMessage(String screenToken, String messageID) {
    firestoreInstance
        .collection('messages')
        .doc(screenToken)
        .collection('message')
        .doc(messageID)
        .delete()
        .then((value) => debugPrint("Deleted message"))
        .onError((error, stackTrace) =>
            debugPrint("unable to delete message: $error"));
  }

  /// Calls the cloud function to retrieve the user's email 
  /// associated with this [screenToken].
  ///
  /// If the email could not be retrieved, an empty string will be returned.
  Future<String> getUsersEmail(String screenToken) async {
    // Retrieve the screen's info
    final usersSnapshot =
        await firestoreInstance.collection('screens').doc(screenToken).get();
    final userDoc = usersSnapshot.data();

    // Ensure that a user has been found.
    // i.e., userID field is not empty.
    String userID = "";
    if (userDoc != null) {
      userID = userDoc["userID"];
    }
    if (userID.isEmpty) return "";

    // Call the cloud function and await the result.
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('getUsersEmail');
    final result = await callable.call(<String, dynamic>{
      'userID': userID,
    });

    // Return an empty string if an email was not returned.
    final String? email = result.data;
    return email ?? "";
  }
}
