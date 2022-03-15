import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diginotescreen/core/models/screen_info_model.dart';

class FirebaseBatteryRepository {
  FirebaseBatteryRepository(
      {required this.firestoreInstance, required this.token});

  final FirebaseFirestore firestoreInstance;
  final String token;

  Future<void> updateBatteryPercentage(int batteryPercentage) async {
    return firestoreInstance.collection('screenInfo').doc(token).set(
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
}
