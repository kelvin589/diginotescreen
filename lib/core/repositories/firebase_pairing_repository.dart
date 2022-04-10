import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/screen_model.dart';
import 'package:diginotescreen/ui/shared/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// The repository to access functionality related to the pairing of a screen.
/// 
/// Add a screen and retrieve [Screen] information.
/// The [init] method must be called to initialise [FirebasePairingRepository].
class FirebasePairingRepository {
  /// Creates a [FirebasePairingRepository] using a [FirebaseFirestore] instance
  /// for a given screen [token], which is their [FirebaseMessaging] token.
  FirebasePairingRepository({required this.firestoreInstance, this.token});

  /// The [FirebaseFirestore] instance.
  final FirebaseFirestore firestoreInstance;

  /// The [FirebaseMessaging] instance.
  late final FirebaseMessaging firebaseMessaging;

  /// The screen token. A [FirebaseMessaging] token.
  String? token;

  /// Get the screen [token].
  String? getToken() => token;

  /// Initialises the [FirebasePairingRepository] by 
  /// retrieving the [token] if it is not set.
  Future<String?> init() async {
    // No mock for FCM. Instead, allow the token to be passed in.
    if (token == null) {
      firebaseMessaging = FirebaseMessaging.instance;
      String? retrievedToken = await firebaseMessaging.getToken();
      token = retrievedToken;
      return token;
    }
    return null;
  }

  /// Add a screen's [pairingCode] along with its [deviceInfo].
  Future<void> addPairingCode(String pairingCode, DeviceInfo deviceInfo) async {
    return firestoreInstance
        .collection('screens')
        .withConverter<Screen>(
          fromFirestore: (snapshot, _) =>
              Screen.fromJson(snapshot.data()!),
          toFirestore: (screen, _) => screen.toJson(),
        )
        .doc(token)
        .set(
            Screen(
              pairingCode: pairingCode,
              paired: false,
              lastUpdated: DateTime.now(),
              name: '',
              screenToken: token!,
              userID: '',
              width: deviceInfo.width,
              height: deviceInfo.safeHeight,
            ),
            SetOptions(merge: true))
        .then((value) => debugPrint("Added pairing code"))
        .catchError((error) => debugPrint("Failed to add pairing code: $error"));
  }

  /// Retrieve a stream of [Screen] for the given [token].
  Stream<Screen?> getStream() {
    return firestoreInstance
        .collection('screens')
        .doc(token)
        .withConverter<Screen>(
          fromFirestore: (snapshot, _) =>
              Screen.fromJson(snapshot.data()!),
          toFirestore: (screen, _) => screen.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.data());
  }
}
