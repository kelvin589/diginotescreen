import 'package:clock/clock.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/providers/firebase_pairing_provider.dart';
import 'package:diginotescreen/core/providers/firebase_preview_provider.dart';
import 'package:diginotescreen/ui/widgets/message_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A positioned [MessageItem] which deletes itself if scheduled to do so.
class PositionedMessageItem extends StatelessWidget {
  /// Creates a [PositionedMessageItem] using the [message].
  const PositionedMessageItem({Key? key, required this.message}) : super(key: key);

  /// The message to be displayed.
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: message.x,
      top: message.y,
      child: Column(
        children: [
          MessageItem(message: message, width: message.width, height: message.height),
          _RemainingTimePanel(
            message: message,
          ),
        ],
      ),
    );
  }
}

/// A panel displaying the remaining time transparently.
/// 
/// After remaining time has passed, the [message] will be deleted.
class _RemainingTimePanel extends StatelessWidget {
  /// Creates a [_RemainingTimePanel] for the [messsage].
  const _RemainingTimePanel({Key? key, required this.message})
      : super(key: key);

  /// The message to be displayed.
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Text(_scheduleText(context),
        style: const TextStyle(color: Colors.transparent));
  }

  /// Determines whether to display the schedule text and to subsequently
  /// delete the [message].
  String _scheduleText(BuildContext context) {
    if (!message.scheduled) return "No Schedule";

    DateTime from = message.from;
    DateTime to = message.to;
    // Already assumed that from is before now (i.e., it should be displayed)
    if (from.isAtSameMomentAs(to)) {
      return "Displaying indefinitely";
    } else if (from.isBefore(to)) {
      if (clock.now().isAfter(to)) {
        // Schedule has passed so delete it
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

  // Code taken from here to represent duration as hours:minutes:seconds:
  // https://stackoverflow.com/questions/54775097/formatting-a-duration-like-hhmmss
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
