import 'package:auto_size_text/auto_size_text.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/providers/firebase_pairing_provider.dart';
import 'package:diginotescreen/core/providers/firebase_preview_provider.dart';
import 'package:diginotescreen/ui/shared/timer_provider.dart';
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
      child: MessageItem(message: message),
    );
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({Key? key, required this.message}) : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(
            minHeight: 100,
            minWidth: 100,
            maxHeight: 100,
            maxWidth: 100,
          ),
          decoration: const BoxDecoration(
            color: Colors.red,
          ),
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                message.header != ""
                    ? Padding(
                        child: Text(message.header),
                        padding: const EdgeInsets.only(bottom: 16.0),
                      )
                    : Container(),
                Expanded(
                  child: Center(
                    child: AutoSizeText(
                      message.message,
                      minFontSize: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _RemainingTimePanel(
          message: message,
        ),
      ],
    );
  }
}

class _RemainingTimePanel extends StatelessWidget {
  const _RemainingTimePanel({Key? key, required this.message})
      : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, value, child) {
        return Text(_scheduleText(context));
      },
    );
  }

  String _scheduleText(BuildContext context) {
    Duration difference = message.to.difference(DateTime.now());
    // If message is scheduled and to is not in the past, show the remaining time
    if (message.scheduled && !difference.isNegative) {
      return _printDuration(difference);
    } else if (message.scheduled && difference.isNegative) {
      // schedule but schedule passed
      String? screenToken =
          Provider.of<FirebasePairingProvider>(context, listen: false)
              .getToken();
      if (screenToken != null) {
        Provider.of<FirebasePreviewProvider>(context, listen: false)
            .deleteMessage(screenToken, message.id);
      }
      return "";
    }
    return "";
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
