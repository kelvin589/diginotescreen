import 'package:clock/clock.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/providers/firebase_battery_reporter_provider.dart';
import 'package:diginotescreen/core/providers/firebase_connectivity_provider.dart';
import 'package:diginotescreen/core/providers/firebase_preview_provider.dart';
import 'package:diginotescreen/ui/shared/timer_provider.dart';
import 'package:diginotescreen/ui/widgets/positioned_message_item.dart';
import 'package:diginotescreen/ui/widgets/qr_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

/// Displays the screen's associated messages.
class PreviewView extends StatefulWidget {
  const PreviewView({Key? key, required this.screenToken}) : super(key: key);

  final String screenToken;

  @override
  _PreviewViewState createState() => _PreviewViewState();
}

class _PreviewViewState extends State<PreviewView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addObserver(this);

    // Initialise providers.
    Provider.of<FirebaseBatteryReporterProvider>(context, listen: false).init();
    Provider.of<FirebaseConnectivityProvider>(context, listen: false).init();
    Provider.of<FirebaseConnectivityProvider>(context, listen: false)
      .notifyDevicesToOnlineStatus(true, "");
  }

  @override
  dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  /// Notify devices to online status if the app is put in the foreground or background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<FirebaseConnectivityProvider>(context, listen: false)
          .notifyDevicesToOnlineStatus(true, "Screen in foreground.");
    }  else if (state == AppLifecycleState.paused) {
      Provider.of<FirebaseConnectivityProvider>(context, listen: false)
          .notifyDevicesToOnlineStatus(false, "Screen in background.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the screen does not sleep.
    Wakelock.enable();

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
              return const Center(child: CircularProgressIndicator());
            }

            Iterable<Message>? screens = snapshot.data;
            if (screens != null) {
              // Consume the timer to update the UI as messages may be scheduled
              return Consumer<TimerProvider>(builder: (context, value, child) {
                List<Widget> items = <Widget>[];
                items = _updateScreenItems(context, screens);
                items.add(QRForm(
                  screenToken: widget.screenToken,
                ));
                return Stack(
                  children: items,
                );
              });
            } else {
              return const Text('Error occurred');
            }
          },
        ),
      ),
    );
  }

  /// Generates the [PositionedMessageItem]s to display the messages.
  List<Widget> _updateScreenItems(
      BuildContext context, Iterable<Message>? messages) {
    List<Widget> messageItems = [];

    if (messages != null) {
      for (Message message in messages) {
        // Display only messages which should be displayed.
        // If the schedule is invalid (i.e., from after to),
        // display the message anyway.
        if (message.from.isBefore(clock.now()) ||
            message.from.isAtSameMomentAs(clock.now()) ||
            message.from.isAfter(message.to)) {
          messageItems.add(PositionedMessageItem(message: message));
        }
      }
    }

    return messageItems;
  }
}
