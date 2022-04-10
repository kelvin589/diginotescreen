import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/repositories/firebase_preview_repository.dart';
import 'package:flutter/material.dart';

/// A provider using the [FirebasePreviewRepository].
///
/// Retrieves and deletes messages, and retrieves the email of the user associated
/// with this screen.
class FirebasePreviewProvider extends ChangeNotifier {
  /// Creates a [FirebasePreviewProvider] using a [FirebaseFirestore] instance.
  ///
  /// Initialises the [FirebasePreviewRepository].
  FirebasePreviewProvider({required FirebaseFirestore firestoreInstance})
      : _previewRepository =
            FirebasePreviewRepository(firestoreInstance: firestoreInstance);

  /// The [FirebasePreviewRepository] instance.
  final FirebasePreviewRepository _previewRepository;

  /// Retrieves a stream of [Message] for the given [screenToken].
  Stream<Iterable<Message>> getMessages(String screenToken) {
    return _previewRepository.getMessages(screenToken);
  }

  /// Deletes the [Message] with [messageID] for the given [screenToken].
  void deleteMessage(String screenToken, String messageID) {
    _previewRepository.deleteMessage(screenToken, messageID);
  }

  /// Retrieves the email of the user associated with this screen.
  Future<String> getUsersEmail(String screenToken) async {
    return await _previewRepository.getUsersEmail(screenToken);
  }
}
