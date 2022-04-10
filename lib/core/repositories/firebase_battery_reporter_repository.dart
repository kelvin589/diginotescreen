import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diginotescreen/core/models/screen_info_model.dart';
import 'package:flutter/material.dart';

/// The repository to deal with battery reporting.
///
/// Updating the current battery percentage, retrieving this screen's [ScreenInfo],
/// and calling a cloud function to notifying devices to low battery.
class FirebaseBatteryReporterRepository {
  /// Creates a [FirebaseBatteryReporterRepository] using a [FirebaseFirestore] and
  /// [FirebaseFunctions] instance, for a given screen [token].
  FirebaseBatteryReporterRepository({
    required this.firestoreInstance,
    required this.functionsInstance,
    required this.token,
  });

  /// The [FirebaseFirestore] instance.
  final FirebaseFirestore firestoreInstance;

  /// The [FirebaseFunctions] instance.
  final FirebaseFunctions functionsInstance;

  /// The screen token.
  final String token;

  /// Update the [batteryPercentage] for this screen [token].
  Future<void> updateBatteryPercentage(int batteryPercentage) async {
    await firestoreInstance.collection('screenInfo').doc(token).set(
      {"batteryPercentage": batteryPercentage},
      SetOptions(merge: true),
    );
  }

  /// Retrieve a stream of this screen [token]s [ScreenInfo].
  Stream<ScreenInfo?> getStream() {
    return firestoreInstance
        .collection('screenInfo')
        .doc(token)
        .withConverter<ScreenInfo>(
          fromFirestore: (snapshot, _) => ScreenInfo.fromJson(snapshot.data()!),
          toFirestore: (screenInfo, _) => screenInfo.toJson(),
        )
        .snapshots()
        .map((event) => event.data());
  }

  /// Calls a cloud function to notify devices, associated with this screen's
  /// userID, to the [batteryLevel].
  Future<void> notifyDevicesToLowBattery(int batteryLevel) async {
    // Call the cloud function and await the result.
    HttpsCallable callable =
        functionsInstance.httpsCallable('notifyDevicesToLowBattery');
    final result = await callable.call(<String, dynamic>{
      'token': token,
      'batteryLevel': batteryLevel,
    });
    debugPrint("result: ${result.data}");
  }
}
