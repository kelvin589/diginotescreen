import 'package:clock/clock.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/providers/firebase_pairing_provider.dart';
import 'package:diginotescreen/core/providers/firebase_preview_provider.dart';
import 'package:diginotescreen/ui/widgets/message_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviewItem extends StatelessWidget {
  const PreviewItem({Key? key, required this.message}) : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: message.x,
      top: message.y,
      child: Column(
        children: [
          MessageItem(message: message, width: 100, height: 100),
          _RemainingTimePanel(
            message: message,
          ),
        ],
      ),
    );
  }
}

class _RemainingTimePanel extends StatelessWidget {
  const _RemainingTimePanel({Key? key, required this.message})
      : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Text(_scheduleText(context),
        style: const TextStyle(color: Colors.transparent));
  }

  String _scheduleText(BuildContext context) {
    if (!message.scheduled) {
      return "No Schedule";
    }

    DateTime from = message.from;
    DateTime to = message.to;
    // already assuming that from is before now (i.e., it should be displayed)
    if (from.isAtSameMomentAs(to)) {
      return "Displaying indefinitely";
    } else if (from.isBefore(to)) {
      if (clock.now().isAfter(to)) {
        // schedule passed so delete it
        String? screenToken =
            Provider.of<FirebasePairingProvider>(context, listen: false)
                .getToken();
        if (screenToken != null) {
          Provider.of<FirebasePreviewProvider>(context, listen: false)
              .deleteMessage(screenToken, message.id);
        }
      }
      Duration difference = message.to.difference(clock.now());
      return _printDuration(difference);
    }
    return "To before From";
  }

  // Code taken from here to represent duration as hours:minutes:seconds
  //https://stackoverflow.com/questions/54775097/formatting-a-duration-like-hhmmss
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
