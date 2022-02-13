import 'package:diginotescreen/ui/widgets/header.dart';
import 'package:flutter/material.dart';

class StarterView extends StatelessWidget {
  const StarterView({Key? key, required this.pairingCode}) : super(key: key);

  static const String route = '/starter';

  final String pairingCode;

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
                children: <Widget>[
                  const Text(
                    'Welcome, enter the following code to pair this screen:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22),
                  ),
                  Text(
                    pairingCode,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
