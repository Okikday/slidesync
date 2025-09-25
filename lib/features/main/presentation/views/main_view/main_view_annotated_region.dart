import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/presentation/providers/main_providers.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class MainViewAnnotatedRegion extends ConsumerWidget {
  final Widget child;
  const MainViewAnnotatedRegion({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.theme;
    final Brightness brightness = theme.brightness;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor:
            ref.watch(MainProviders.isMainScrolledProvider) ? theme.secondaryColor.withAlpha(100) : theme.background,
        statusBarBrightness: brightness,
        statusBarIconBrightness: brightness,
        systemNavigationBarIconBrightness: brightness,
        systemNavigationBarColor: context.theme.cardColor,
      ),

      child: child,
    );
  }
}
