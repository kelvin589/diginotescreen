import 'package:auto_size_text/auto_size_text.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                ? AutoSizeText(
                    message.header,
                    minFontSize: 3,
                    style: GoogleFonts.getFont(message.fontFamily,
                        fontSize: message.fontSize, color: Color(message.foregroundColour)),
                  )
                : Container(),
            Expanded(
              child: Center(
                child: AutoSizeText(
                  message.message,
                  minFontSize: 3,
                  style: GoogleFonts.getFont(message.fontFamily,
                      fontSize: message.fontSize,
                      color: Color(message.foregroundColour)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
