import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRForm extends StatelessWidget {
  const QRForm({Key? key}) : super(key: key);

  final googleFormLink = "https://docs.google.com/forms/d/e/1FAIpQLSej0ncn2ktr0zzV9z5wwlH8TbdryoyPYsMTw3lVvt11fSz8LQ/viewform?usp=pp_url&entry.1351482419=";
  final email = "email@domain.com";

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
