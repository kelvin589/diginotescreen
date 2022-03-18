import 'dart:async';

import 'package:clock/clock.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:diginotescreen/core/models/messages_model.dart';
import 'package:diginotescreen/core/providers/firebase_battery_reporter_provider.dart';
import 'package:diginotescreen/core/providers/firebase_connectivity_provider.dart';
import 'package:diginotescreen/core/providers/firebase_preview_provider.dart';
import 'package:diginotescreen/ui/shared/timer_provider.dart';
import 'package:diginotescreen/ui/widgets/preview_item.dart';
import 'package:diginotescreen/ui/widgets/qr_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    Provider.of<FirebaseBatteryReporterProvider>(context, listen: false).init();
    // Provider.of<FirebaseConnectivityProvider>(context, listen: false).init();
    Provider.of<FirebaseConnectivityProvider>(context, listen: false)
      .notifyDevicesToOnlineStatus(true, "");
  }

  @override
  dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<FirebaseConnectivityProvider>(context, listen: false)
          .notifyDevicesToOnlineStatus(true, "Screen in foreground.");
    } else if (state == AppLifecycleState.detached) {
      Provider.of<FirebaseConnectivityProvider>(context, listen: false)
          .notifyDevicesToOnlineStatus(false, "Screen was closed.");
    }  else if (state == AppLifecycleState.paused) {
      Provider.of<FirebaseConnectivityProvider>(context, listen: false)
          .notifyDevicesToOnlineStatus(false, "Screen in background.");
    }
  }

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
              return const Center(child: CircularProgressIndicator());
            }

            Iterable<Message>? screens = snapshot.data;
            if (screens != null) {
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

  List<Widget> _updateScreenItems(
      BuildContext context, Iterable<Message>? messages) {
    List<Widget> messageItems = [];

    if (messages != null) {
      for (Message message in messages) {
        if (message.from.isBefore(clock.now()) ||
            message.from.isAtSameMomentAs(clock.now()) ||
            message.from.isAfter(message.to)) {
          messageItems.add(PreviewItem(message: message));
        }
      }
    }

    return messageItems;
  }
}
