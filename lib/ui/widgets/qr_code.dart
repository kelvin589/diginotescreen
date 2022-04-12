import 'package:diginotescreen/core/providers/firebase_preview_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Displays a QR code which, once scanned, takes viewers to a Google Forms
/// to submit a message to the owner of this screen.
///
/// The form is pre-populated with the owner's email address, if found.
class QRCode extends StatefulWidget {
  /// Creates a [QRCode] for the screen with [screenToken].
  const QRCode({Key? key, required this.screenToken}) : super(key: key);

  /// The screen token.
  final String screenToken;

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  /// The link to the Google Forms.
  final googleFormLink =
      "https://docs.google.com/forms/d/e/1FAIpQLSej0ncn2ktr0zzV9z5wwlH8TbdryoyPYsMTw3lVvt11fSz8LQ/viewform?usp=pp_url&entry.1351482419=";

  /// The owner's email address.
  String email = "";

  @override
  void initState() {
    super.initState();
    // Retrieve the email address.
    Provider.of<FirebasePreviewProvider>(context, listen: false)
        .getUsersEmail(widget.screenToken)
        .then((retrievedEmail) => email = retrievedEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        width: 110,
        padding: const EdgeInsets.only(left: 4.0),
        child: Column(
          children: [
            QrImage(
              data: googleFormLink + email,
              version: QrVersions.auto,
              size: 100.0,
            ),
            const Text(
                "Scan the QR code to send an email to the staff member."),
          ],
        ),
      ),
    );
  }
}
