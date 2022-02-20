import 'package:diginotescreen/core/providers/firebase_pairing_provider.dart';
import 'package:diginotescreen/firebase_options.dart';
import 'package:diginotescreen/ui/views/home_view.dart';
import 'package:diginotescreen/ui/views/starter_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirebasePairingProvider pairingProvider = FirebasePairingProvider();
  await pairingProvider.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => pairingProvider),
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
      initialRoute: StarterView.route,
      routes: {
        StarterView.route: (context) => const StarterView(),
        HomeView.route: (context) => const HomeView(),
      },
    );
  }
}
