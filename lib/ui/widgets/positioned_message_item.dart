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
  const PositionedMessageItem({Key? key, required this.message})
      : super(key: key);

  /// The message to be displayed.
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: message.x,
      top: message.y,
      child: Column(
        children: [
          MessageItem(
            message: message,
            width: message.width,
            height: message.height,
          ),
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
  /// Creates a [_RemainingTimePanel] for the [message].
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
  ///
  /// Scheduling may be in one of five states:
  ///	  1. From = to <= now: scheduled for now, indefinitely.
  ///   2. From = to > now: scheduled in the future, indefinitely.
  ///   3. From > now && to > now: scheduled in the future, for a set period.
  ///   4. From = now && to > from: scheduled for now, for a set period
  ///   5. From > To: displays indefinitely (invalid but it shouldn't be possible anyway).
  String _scheduleText(BuildContext context) {
    DateTime now = clock.now();

    if (!message.scheduled) return "No Schedule";

    // from == to: displayed indefinitely.
    if (message.from.isAtSameMomentAs(message.to)) {
      // from > now: scheduled for the future.
      return message.from.isAfter(now) ? "Scheduled" : "Indefinite";
      // to > from: displayed for a set period.
    } else if (message.to.isAfter(message.from)) {
      // Calculate the difference from now until to.
      Duration difference = message.to.difference(now);

      // from > now: scheduled for the future.
      if (message.from.isAfter(now)) return "Scheduled";

      // We have not reached to.
      if (!difference.isNegative) {
        return _printDuration(difference);
        // Otherwise, the schedule has passed.
      } else if (difference.isNegative) {
        // Remove the message.
        String? screenToken =
            Provider.of<FirebasePairingProvider>(context, listen: false)
                .getToken();
        if (screenToken != null) {
          Provider.of<FirebasePreviewProvider>(context, listen: false)
              .deleteMessage(screenToken, message.id);
        }
      }
    }

    // Some undefined from and to combination.
    return "Undefined";
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
