import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class PairingCodeText extends StatefulWidget {
  const PairingCodeText({Key? key, required this.onPairingCodeGenerated})
      : super(key: key);

  final void Function(String) onPairingCodeGenerated;

  final int pairingCodeLength = 6;
  final int refreshDuration = 600;

  @override
  _PairingCodeTextState createState() => _PairingCodeTextState();
}

class _PairingCodeTextState extends State<PairingCodeText> {
  Timer? timer;
  String pairingCode = "";

  @override
  void initState() {
    super.initState();
    generatePairingCode();
    timer = Timer.periodic(Duration(seconds: widget.refreshDuration),
        (timer) => generatePairingCode());
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
      widget.onPairingCodeGenerated(pairingCode);
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
