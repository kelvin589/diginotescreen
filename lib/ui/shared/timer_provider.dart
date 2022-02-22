import 'dart:async';

import 'package:flutter/material.dart';

class TimerProvider extends ChangeNotifier {
  TimerProvider({required this.duration}) {
    timer = Timer.periodic(duration, (timer) { 
      print("test");
      notifyListeners();
    });
  }

  final Duration duration;
  Timer? timer;

  void startTimer() {
    print("test");
  }

  void stopTimer() {
    print("STOP");  
    timer?.cancel();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stopTimer();
  }
}