import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diginotescreen/core/providers/firebase_battery_reporter_provider.dart';
import 'package:diginotescreen/core/providers/firebase_connectivity_provider.dart';
import 'package:diginotescreen/core/providers/firebase_pairing_provider.dart';
import 'package:diginotescreen/core/providers/firebase_preview_provider.dart';
import 'package:diginotescreen/firebase_options.dart';
import 'package:diginotescreen/ui/views/starter_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  FirebaseFunctions functionsInstance = FirebaseFunctions.instance;
  FirebaseDatabase realtimeInstance = FirebaseDatabase.instance;

  final FirebasePairingProvider pairingProvider =
      FirebasePairingProvider(firestoreInstance: firestoreInstance);
  final FirebasePreviewProvider previewProvider =
      FirebasePreviewProvider(firestoreInstance: firestoreInstance);

  await pairingProvider.init();

  final FirebaseBatteryReporterProvider batteryReporterProvider =
      FirebaseBatteryReporterProvider(
    firestoreInstance: firestoreInstance,
    functionsInstance: functionsInstance,
    token: pairingProvider.getToken() ?? "Unknown",
  );
  // Init when showing preview
  // await batteryReporterProvider.init();

  final FirebaseConnectivityProvider connectivityProvider =
      FirebaseConnectivityProvider(
    firestoreInstance: firestoreInstance,
    functionsInstance: functionsInstance,
    realtimeInstance: realtimeInstance,
    token: pairingProvider.getToken() ?? "Unknown",
  );
  // Init when showing preview
  // connectivityProvider.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => pairingProvider),
      ChangeNotifierProvider(create: (context) => previewProvider),
      ChangeNotifierProvider(create: (context) => batteryReporterProvider),
      ChangeNotifierProvider(create: (context) => connectivityProvider),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const Scaffold(
        body: StarterView(),
      ),
    );
  }
}
