import 'package:diginotescreen/core/models/screen_model.dart';
import 'package:diginotescreen/core/providers/firebase_pairing_provider.dart';
import 'package:diginotescreen/ui/shared/device_info.dart';
import 'package:diginotescreen/ui/shared/timer_provider.dart';
import 'package:diginotescreen/ui/views/preview_view.dart';
import 'package:diginotescreen/ui/widgets/header.dart';
import 'package:diginotescreen/ui/widgets/pairing_code_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StarterView extends StatelessWidget {
  const StarterView({Key? key}) : super(key: key);

  static const String route = '/starter';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Screen?>(
      stream: Provider.of<FirebasePairingProvider>(context, listen: false)
          .getStream(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${(snapshot.error.toString())}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        Screen? screen = snapshot.data;
        if (screen != null && screen.paired) {
          return ChangeNotifierProvider(
            create: (context) =>
                TimerProvider(duration: const Duration(seconds: 1)),
            child: PreviewView(
              screenToken: screen.screenToken,
            ),
          );
        } else {
          return MainView(
            mainContext: context,
          );
        }
      },
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({Key? key, required this.mainContext}) : super(key: key);

  final BuildContext mainContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            const Header(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Welcome, enter the following code to pair this screen:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22),
                  ),
                  PairingCodeText(
                    onPairingCodeGenerated: (pairingCode) async {
                      await Provider.of<FirebasePairingProvider>(context,
                              listen: false)
                          .addPairingCode(
                              pairingCode, DeviceInfo(context: context));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
