import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:flutter/material.dart';

class PreviewItem extends StatelessWidget {
  const PreviewItem({Key? key, required this.message}) : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: message.x,
      top: message.y,
      child: Container(
        color: Colors.red,
        child: MessageItem(message: message),
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({Key? key, required this.message})
      : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Flexible(child: Text(message.message)),
          ],
        ),
      ),
    );
  }
}
