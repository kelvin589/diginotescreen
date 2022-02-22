import 'package:auto_size_text/auto_size_text.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
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
            from: message.from, to: message.to, scheduled: message.scheduled),
      ],
    );
  }
}

class _RemainingTimePanel extends StatelessWidget {
  const _RemainingTimePanel(
      {Key? key, required this.from, required this.to, required this.scheduled})
      : super(key: key);

  final DateTime from;
  final DateTime to;
  final bool scheduled;

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, value, child) {
        return Text(_scheduleText());
      },
    );
  }

  String _scheduleText() {
    Duration difference = to.difference(DateTime.now());
    // If message is scheduled and to is not in the past, show the remaining time
    if (scheduled && !difference.isNegative) {
      return _printDuration(difference);
    } else {
      return "No Schedule";
    }
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
