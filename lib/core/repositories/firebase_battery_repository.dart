import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/screen_info_model.dart';

class FirebaseBatteryRepository {
  FirebaseBatteryRepository(
      {required this.firestoreInstance, required this.token});

  final FirebaseFirestore firestoreInstance;
  final String token;

  Future<void> updateBatteryPercentage(int batteryPercentage) async {
    return firestoreInstance
        .collection('screenInfo')
        .doc(token)
        .withConverter<ScreenInfo>(
          fromFirestore: (snapshot, _) => ScreenInfo.fromJson(snapshot.data()!),
          toFirestore: (screenInfo, _) => screenInfo.toJson(),
        )
        .set(
          ScreenInfo(screenToken: token, batteryPercentage: batteryPercentage),
          SetOptions(merge: true),
        );
  }
}
