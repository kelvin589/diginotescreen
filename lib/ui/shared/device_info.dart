import 'package:flutter/material.dart';

class DeviceInfo {
  DeviceInfo({required BuildContext context})
      : width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height,
        viewPadding = MediaQuery.of(context).viewPadding;

  DeviceInfo.withValues(
      {required this.width, required this.height, required this.viewPadding});

  final double width;
  final double height;
  final EdgeInsets viewPadding;

  double get safeHeight => height - viewPadding.top - viewPadding.bottom;
}
