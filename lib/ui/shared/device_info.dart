import 'package:flutter/material.dart';

/// The device info about the width, height and view padding of a device.
class DeviceInfo {
  /// Initialises the [width], [height] and [viewPadding] of a device
  /// based on the [context].
  DeviceInfo({required BuildContext context})
      : width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height,
        viewPadding = MediaQuery.of(context).viewPadding;

  /// Named constructor to create [DeviceInfo] without a [BuildContext].
  DeviceInfo.withValues(
      {required this.width, required this.height, required this.viewPadding});

  /// The logical pixel width of this screen.
  final double width;

  /// The logical pixel height of this screen.
  final double height;

  /// The vide padding of this screen.
  final EdgeInsets viewPadding;

  /// The safe height to place widgets; reduced from the top and bottm of [viewPadding].
  double get safeHeight => height - viewPadding.top - viewPadding.bottom;
}
