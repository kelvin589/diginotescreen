import 'package:diginotescreen/core/providers/firebase_preview_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRForm extends StatefulWidget {
  const QRForm({Key? key, required this.screenToken}) : super(key: key);

  final String screenToken;

  @override
  State<QRForm> createState() => _QRFormState();
}

class _QRFormState extends State<QRForm> {
  final googleFormLink =
      "https://docs.google.com/forms/d/e/1FAIpQLSej0ncn2ktr0zzV9z5wwlH8TbdryoyPYsMTw3lVvt11fSz8LQ/viewform?usp=pp_url&entry.1351482419=";
  String email = "";

  @override
  void initState() {
    super.initState();
    Provider.of<FirebasePreviewProvider>(context, listen: false)
        .getUsersEmail(widget.screenToken)
        .then((retrievedEmail) => email = retrievedEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: QrImage(
        data: googleFormLink + email,
        version: QrVersions.auto,
        size: 100.0,
      ),
    );
  }
}
