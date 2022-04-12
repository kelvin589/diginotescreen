import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// Generates and displays a random alphanumeric pairing code of length [pairingCodeLength]
/// every [refreshDuration] seconds.
class PairingCodeText extends StatefulWidget {
  /// Creates the [PairingCodeText] which invokes the [onPairingCodeGenerated]
  /// callback every time a new code is generated.
  const PairingCodeText({Key? key, required this.onPairingCodeGenerated})
      : super(key: key);

  /// A callback function which is called with the generated pairing code.
  final void Function(String) onPairingCodeGenerated;

  /// The length of the pairing code.
  final int pairingCodeLength = 6;

  /// The number of seconds after which a new pairing code is generated.
  final int refreshDuration = 600;

  @override
  _PairingCodeTextState createState() => _PairingCodeTextState();
}

class _PairingCodeTextState extends State<PairingCodeText> {
  /// The timer which generates a new pairing code after [refreshDuration] seconds.
  Timer? timer;

  /// The current pairing code.
  String pairingCode = "";

  @override
  void initState() {
    super.initState();
    // Must generate an iniital pairing code.
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

  /// Updates the pairing code text.
  void generatePairingCode() {
    setState(() {
      pairingCode = _randomString(widget.pairingCodeLength);
      widget.onPairingCodeGenerated(pairingCode);
    });
  }

  /// Generates a random alphanumeric string of given [length].
  String _randomString(int length) {
    const String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final Random random = Random();
    String randomString = "";

    // For each character of the randomString, pick a random character from characters.
    for (int index = 0; index < length; index++) {
      randomString += characters[random.nextInt(characters.length)];
    }

    return randomString;
  }
}
