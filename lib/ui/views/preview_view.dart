import 'package:clock/clock.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/providers/firebase_preview_provider.dart';
import 'package:diginotescreen/ui/widgets/preview_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({Key? key, required this.screenToken}) : super(key: key);

  final String screenToken;

  @override
  _PreviewViewState createState() => _PreviewViewState();
}

class _PreviewViewState extends State<PreviewView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<Iterable<Message>>(
          stream: Provider.of<FirebasePreviewProvider>(context, listen: false)
              .getMessages(widget.screenToken),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error ${(snapshot.error.toString())}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Waiting');
            }

            Iterable<Message>? screens = snapshot.data;
            if (screens != null) {
              List<Widget> items = <Widget>[];
              items = _updateScreenItems(context, screens);
              return Stack(
                children: items,
              );
            } else {
              return const Text('Error occurred');
            }
          },
        ),
      ),
    );
  }

  List<Widget> _updateScreenItems(
      BuildContext context, Iterable<Message>? messages) {
    List<Widget> messageItems = [];

    if (messages != null) {
      for (Message message in messages) {
        if (message.from.isBefore(clock.now()) || message.from.isAtSameMomentAs(clock.now())) {
          messageItems.add(PreviewItem(message: message));
        }
      }
    }

    return messageItems;
  }
}
