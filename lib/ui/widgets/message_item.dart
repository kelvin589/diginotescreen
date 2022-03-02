import 'package:auto_size_text/auto_size_text.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({
    Key? key,
    required this.message,
    required this.width,
    required this.height,
  }) : super(key: key);

  final Message message;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: height,
        minWidth: width,
        maxHeight: height,
        maxWidth: width,
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
    );
  }
}
