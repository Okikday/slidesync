import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).custom;
    return Row(
      spacing: 8,
      mainAxisAlignment: .start,
      children: [
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: LoadingLogo(animate: false, color: customTheme.primary),
        ),
        CustomText(
          'SlideSync',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: customTheme.onBackground,
          ),
        ),
      ],
    );
  }
}
