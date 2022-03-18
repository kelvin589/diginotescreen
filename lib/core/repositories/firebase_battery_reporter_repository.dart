import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diginotescreen/core/models/screen_info_model.dart';

class FirebaseBatteryReporterRepository {
  FirebaseBatteryReporterRepository(
      {required this.firestoreInstance, required this.functionsInstance, required this.token});

  final FirebaseFirestore firestoreInstance;
  final FirebaseFunctions functionsInstance;
  final String token;

  Future<void> updateBatteryPercentage(int batteryPercentage) async {
    await firestoreInstance.collection('screenInfo').doc(token).set(
      {"batteryPercentage": batteryPercentage},
      SetOptions(merge: true),
    );
  }

  Stream<ScreenInfo?> getStream() {
    return firestoreInstance
        .collection('screenInfo')
        .doc(token)
        .withConverter<ScreenInfo>(
          fromFirestore: (snapshot, _) => ScreenInfo.fromJson(snapshot.data()!),
          toFirestore: (screenInfo, _) => screenInfo.toJson(),
        )
        .snapshots().map((event) => event.data());
  }

  Future<void> notifyDevicesToLowBattery(int batteryLevel) async {
    HttpsCallable callable =
        functionsInstance.httpsCallable('notifyDevicesToLowBattery');
    final result = await callable.call(<String, dynamic>{
      'token': token,
      'batteryLevel': batteryLevel,
    });
    print("result: ${result.data}");
  }
}
