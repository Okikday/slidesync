import 'package:flutter/material.dart';
import 'package:slidesync/core/utils/device_utils.dart';

class DesktopWidget extends StatelessWidget {
  final Widget Function(BuildContext context, bool isDesktop) builder;
  const DesktopWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context) =>
      builder(context, DeviceUtils.isDesktopSize(context));
}
