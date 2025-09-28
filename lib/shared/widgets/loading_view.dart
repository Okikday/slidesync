import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/components/loading_logo.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class LoadingView extends ConsumerWidget {
  final String msg;
  const LoadingView({super.key, this.msg = "Loading..."});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 124),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstantSizing.columnSpacingMedium,
            LoadingLogo(color: ref.primary, size: 64),
            if (msg.isNotEmpty) ConstantSizing.columnSpacingMedium,
            if (msg.isNotEmpty) CustomText(msg, color: ref.onBackground),
          ],
        ),
      ),
    );
  }
}
