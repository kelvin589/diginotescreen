import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/repositories/firebase_preview_repository.dart';
import 'package:flutter/material.dart';

class FirebasePreviewProvider extends ChangeNotifier {
  FirebasePreviewProvider({required FirebaseFirestore firestoreInstance})
      : _previewRepository =
            FirebasePreviewRepository(firestoreInstance: firestoreInstance);

  final FirebasePreviewRepository _previewRepository;

  Stream<Iterable<Message>> getMessages(String screenToken) {
    return _previewRepository.getMessages(screenToken);
  }

  void deleteMessage(String screenToken, String messageID) {
    _previewRepository.deleteMessage(screenToken, messageID);
  }
}
