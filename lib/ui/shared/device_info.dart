import 'package:flutter/material.dart';

class DeviceInfo {
  DeviceInfo({required this.context});

  final BuildContext context;

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get safeHeight => height - viewPadding.top - viewPadding.bottom;
}
