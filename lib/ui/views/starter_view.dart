import 'dart:math';

import 'package:diginotescreen/ui/views/home_view.dart';
import 'package:diginotescreen/ui/widgets/header.dart';
import 'package:flutter/material.dart';

class StarterView extends StatelessWidget {
  const StarterView({Key? key}) : super(key: key);

  static const String route = '/starter';

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

  @override
  __PairingCodeState createState() => __PairingCodeState();
}

class __PairingCodeState extends State<_PairingCode> {
  @override
  Widget build(BuildContext context) {
    return Text(
      _randomString(widget.pairingCodeLength),
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
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
