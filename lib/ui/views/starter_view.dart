import 'dart:async';
import 'dart:math';

import 'package:diginotescreen/core/models/screen_pairing_model.dart';
import 'package:diginotescreen/core/providers/firebase_pairing_provider.dart';
import 'package:diginotescreen/ui/views/home_view.dart';
import 'package:diginotescreen/ui/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StarterView extends StatelessWidget {
  const StarterView({ Key? key }) : super(key: key);

  static const String route = '/starter';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ScreenPairing?>(
      stream: Provider.of<FirebasePairingProvider>(context, listen: false).getStream(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${(snapshot.error.toString())}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Waiting');
        }

        ScreenPairing? screenPairing = snapshot.data;
        if (screenPairing != null && screenPairing.paired) {
          return const HomeView();
        } else {
          return const MainView();
        }
      },
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            const Header(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const <Widget>[
                  Text(
                    'Welcome, enter the following code to pair this screen:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22),
                  ),
                  _PairingCode(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PairingCode extends StatefulWidget {
  const _PairingCode({Key? key}) : super(key: key);

  final int pairingCodeLength = 6;
  final int refreshDuration = 60;

  @override
  __PairingCodeState createState() => __PairingCodeState();
}

class __PairingCodeState extends State<_PairingCode> {
  Timer? timer;
  String pairingCode = "";

  @override
  void initState() {
    super.initState();
    generatePairingCode();
    timer = Timer.periodic(Duration(seconds: widget.refreshDuration), (timer) => generatePairingCode());
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      pairingCode,
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }

  void generatePairingCode() {
    setState(() {
      pairingCode = _randomString(widget.pairingCodeLength);
      Provider.of<FirebasePairingProvider>(context, listen: false).addPairingCode(pairingCode);
    });
  }

  String _randomString(int length) {
    const String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final Random random = Random();
    String randomString = "";

    for (int index = 0; index < length; index++) {
      randomString += characters[random.nextInt(characters.length)];
    }

    return randomString;
  }
}
